//! Package Manager panel host.
//! Pure draw logic; receives `self: anytype` (*App duck-typed) so this file
//! never imports root.zig and therefore has no circular dependency.

const std = @import("std");
const zui = @import("ziggy-ui");
const zcolors = zui.theme.colors;
const Rect = zui.core.Rect;
const PanelLayoutMetrics = zui.ui.layout.form_layout.Metrics;

pub fn draw(self: anytype, manager: anytype, rect: anytype) void {
    _ = manager;
    self.requestPackageManagerRefresh(false);

    const panel_rect = Rect{ .min = rect.min, .max = rect.max };
    self.drawSurfacePanel(panel_rect);

    const layout = self.panelLayoutMetrics();
    const pad = layout.inset;
    const inner_w = @max(1.0, panel_rect.width() - pad * 2.0);
    const line_h = self.textLineHeight();
    const button_h = layout.button_height;

    const refresh_label = if (self.package_manager_refresh_busy) "Loading..." else "Refresh";
    const refresh_w = @max(96.0 * self.ui_scale, self.measureTextFast(refresh_label) + pad * 1.4);
    const refresh_rect = Rect.fromXYWH(
        panel_rect.max[0] - pad - refresh_w,
        panel_rect.min[1] + pad,
        refresh_w,
        button_h,
    );
    if (self.drawButtonWidget(refresh_rect, refresh_label, .{
        .variant = .secondary,
        .disabled = self.connection_state != .connected or self.package_manager_refresh_busy,
    })) {
        self.requestPackageManagerRefresh(true);
    }

    self.drawTextTrimmed(
        panel_rect.min[0] + pad,
        panel_rect.min[1] + pad,
        @max(1.0, refresh_rect.min[0] - panel_rect.min[0] - pad * 1.6),
        "Packages",
        self.theme.colors.text_primary,
    );

    var subtitle_buf: [160]u8 = undefined;
    const subtitle: []const u8 = if (self.package_manager_modal_error) |err_msg|
        err_msg
    else if (self.package_manager_packages.items.len == 0 and self.connection_state == .connected)
        "No packages loaded yet  |  refresh to inspect host and registry state"
    else if (self.connection_state != .connected)
        "Disconnected  |  connect to inspect packages"
    else
        std.fmt.bufPrint(
            &subtitle_buf,
            "{d} packages  |  latest registry metadata and release history included",
            .{self.package_manager_packages.items.len},
        ) catch "Packages loaded";

    self.drawTextTrimmed(
        panel_rect.min[0] + pad,
        panel_rect.min[1] + pad + line_h + layout.row_gap * 0.35,
        inner_w,
        subtitle,
        if (self.package_manager_modal_error != null) zcolors.rgba(220, 80, 60, 255) else self.theme.colors.text_secondary,
    );

    const content_top = panel_rect.min[1] + pad + line_h * 2.0 + layout.row_gap;
    const content_h = @max(1.0, panel_rect.max[1] - content_top - pad);
    const list_w = @max(260.0 * self.ui_scale, inner_w * 0.4);
    const gap = @max(layout.inner_inset, 8.0 * self.ui_scale);
    const list_rect = Rect.fromXYWH(panel_rect.min[0] + pad, content_top, list_w, content_h);
    const detail_rect = Rect.fromXYWH(list_rect.max[0] + gap, content_top, @max(1.0, panel_rect.max[0] - list_rect.max[0] - pad - gap), content_h);

    drawListPane(self, list_rect, pad, line_h, layout);
    drawDetailPane(self, detail_rect, pad, line_h, button_h, layout);
}

fn drawListPane(self: anytype, rect: Rect, pad: f32, line_h: f32, layout: PanelLayoutMetrics) void {
    self.drawSurfacePanel(rect);
    const row_gap = @max(3.0 * self.ui_scale, layout.inner_inset * 0.3);
    const row_h = @max(line_h * 2.0, 46.0 * self.ui_scale);
    const channel_w = @max(72.0 * self.ui_scale, self.measureTextFast("stable") + pad);
    const name_w = @max(1.0, rect.width() - pad * 2.0 - channel_w - pad * 0.5);

    self.drawTextTrimmed(rect.min[0] + pad, rect.min[1] + pad, rect.width() - pad * 2.0, "Installed Packages", self.theme.colors.text_primary);

    if (self.package_manager_packages.items.len == 0) {
        self.drawTextTrimmed(rect.min[0] + pad, rect.min[1] + pad + line_h + pad, rect.width() - pad * 2.0, "(none)", self.theme.colors.text_secondary);
        return;
    }

    var y = rect.min[1] + pad + line_h + row_gap;
    const avail_h = @max(1.0, rect.max[1] - y - pad);
    const max_rows = @as(usize, @intFromFloat(@max(1.0, avail_h / (row_h + row_gap))));
    var drawn: usize = 0;
    for (self.package_manager_packages.items, 0..) |entry, idx| {
        if (drawn >= max_rows) break;
        const is_selected = idx == self.package_manager_selected_index;
        const row_rect = Rect.fromXYWH(rect.min[0], y, rect.width(), row_h);
        const hovered = row_rect.contains(.{ self.mouse_x, self.mouse_y });
        const fill = if (is_selected)
            zcolors.withAlpha(self.theme.colors.primary, 0.16)
        else if (hovered)
            zcolors.withAlpha(self.theme.colors.primary, 0.07)
        else
            zcolors.withAlpha(self.theme.colors.surface, 0.0);
        if (is_selected or hovered) self.drawFilledRect(row_rect, fill);

        const latest_version = entry.latest_release_version orelse "-";
        const active_version = entry.active_release_version orelse entry.version;
        var state_buf: [96]u8 = undefined;
        const state_line = std.fmt.bufPrint(
            &state_buf,
            "{s} -> {s}  |  {s}",
            .{
                active_version,
                latest_version,
                if (entry.update_available) "update available" else "current",
            },
        ) catch active_version;

        const name_x = rect.min[0] + pad;
        self.drawTextTrimmed(name_x, y + (row_h - line_h * 2.0) * 0.5, name_w, entry.package_id, if (is_selected) self.theme.colors.primary else self.theme.colors.text_primary);
        self.drawTextTrimmed(name_x, y + (row_h - line_h * 2.0) * 0.5 + line_h, name_w, state_line, self.theme.colors.text_secondary);

        const badge_x = rect.min[0] + pad + name_w + pad * 0.5;
        const badge_rect = Rect.fromXYWH(badge_x, y + (row_h - line_h) * 0.5, channel_w, line_h);
        self.drawFilledRect(
            badge_rect,
            zcolors.withAlpha(if (entry.update_available) self.theme.colors.primary else self.theme.colors.border, 0.16),
        );
        self.drawTextTrimmed(
            badge_rect.min[0] + pad * 0.35,
            badge_rect.min[1],
            channel_w - pad * 0.5,
            entry.effective_channel orelse entry.latest_release_channel orelse "-",
            if (entry.update_available) self.theme.colors.primary else self.theme.colors.text_secondary,
        );

        if (self.mouse_released and row_rect.contains(.{ self.mouse_x, self.mouse_y })) {
            self.package_manager_selected_index = idx;
        }

        y += row_h + row_gap;
        drawn += 1;
    }

    if (self.package_manager_packages.items.len > drawn) {
        var more_buf: [48]u8 = undefined;
        const more = std.fmt.bufPrint(&more_buf, "...and {d} more", .{self.package_manager_packages.items.len - drawn}) catch "...";
        self.drawTextTrimmed(rect.min[0] + pad, rect.max[1] - pad - line_h, rect.width() - pad * 2.0, more, self.theme.colors.text_secondary);
    }
}

fn drawDetailPane(self: anytype, rect: Rect, pad: f32, line_h: f32, button_h: f32, layout: PanelLayoutMetrics) void {
    self.drawSurfacePanel(rect);

    const idx = if (self.package_manager_packages.items.len == 0) null else self.package_manager_selected_index;
    if (idx == null or idx.? >= self.package_manager_packages.items.len) {
        self.drawTextTrimmed(rect.min[0] + pad, rect.min[1] + pad, rect.width() - pad * 2.0, "Select a package to inspect release/channel state", self.theme.colors.text_secondary);
        return;
    }
    const entry = self.package_manager_packages.items[idx.?];
    const row_gap = pad * 0.4;
    var y = rect.min[1] + pad;

    self.drawTextTrimmed(rect.min[0] + pad, y, rect.width() - pad * 2.0, entry.package_id, self.theme.colors.text_primary);
    y += line_h + row_gap;

    const accent_rect = Rect.fromXYWH(rect.min[0], rect.min[1], @max(3.0, 4.0 * self.ui_scale), rect.height());
    self.drawFilledRect(accent_rect, if (entry.update_available) self.theme.colors.primary else self.theme.colors.border);

    const detail_lines = [_][2][]const u8{
        .{ "Kind", entry.kind },
        .{ "Runtime", entry.runtime_kind },
        .{ "Enabled", if (entry.enabled) "true" else "false" },
        .{ "Active release", entry.active_release_version orelse entry.version },
        .{ "Latest release", entry.latest_release_version orelse "-" },
        .{ "Latest channel", entry.latest_release_channel orelse "-" },
        .{ "Effective channel", entry.effective_channel orelse "-" },
        .{ "Channel override", entry.channel_override orelse "(none)" },
    };

    const label_w = @max(120.0 * self.ui_scale, self.measureTextFast("Installed releases") + pad);
    const value_w = @max(1.0, rect.width() - pad * 2.0 - label_w);
    for (detail_lines) |pair| {
        if (y + line_h > rect.max[1] - pad - button_h * 2.5) break;
        self.drawTextTrimmed(rect.min[0] + pad, y, label_w, pair[0], self.theme.colors.text_secondary);
        self.drawTextTrimmed(rect.min[0] + pad + label_w, y, value_w, pair[1], self.theme.colors.text_primary);
        y += line_h + row_gap;
    }

    var count_buf: [48]u8 = undefined;
    const release_count = std.fmt.bufPrint(&count_buf, "{d}", .{entry.installed_release_count}) catch "0";
    self.drawTextTrimmed(rect.min[0] + pad, y, label_w, "Installed releases", self.theme.colors.text_secondary);
    self.drawTextTrimmed(rect.min[0] + pad + label_w, y, value_w, release_count, self.theme.colors.text_primary);
    y += line_h + row_gap;

    var history_buf: [48]u8 = undefined;
    const history_count = std.fmt.bufPrint(&history_buf, "{d}", .{entry.release_history_count}) catch "0";
    self.drawTextTrimmed(rect.min[0] + pad, y, label_w, "Release history", self.theme.colors.text_secondary);
    self.drawTextTrimmed(rect.min[0] + pad + label_w, y, value_w, history_count, self.theme.colors.text_primary);
    y += line_h + row_gap;

    self.drawTextTrimmed(rect.min[0] + pad, y, label_w, "Update available", self.theme.colors.text_secondary);
    self.drawTextTrimmed(rect.min[0] + pad + label_w, y, value_w, if (entry.update_available) "true" else "false", if (entry.update_available) self.theme.colors.primary else self.theme.colors.text_primary);
    y += line_h + row_gap;

    if (entry.last_release_action) |last_action| {
        self.drawTextTrimmed(rect.min[0] + pad, y, label_w, "Last action", self.theme.colors.text_secondary);
        self.drawTextTrimmed(rect.min[0] + pad + label_w, y, value_w, last_action, self.theme.colors.text_primary);
        y += line_h + row_gap;
    }
    if (entry.last_release_version) |last_release_version| {
        self.drawTextTrimmed(rect.min[0] + pad, y, label_w, "Last version", self.theme.colors.text_secondary);
        self.drawTextTrimmed(rect.min[0] + pad + label_w, y, value_w, last_release_version, self.theme.colors.text_primary);
        y += line_h + row_gap;
    }

    if (entry.help_md) |help_md| {
        y += row_gap * 0.5;
        self.drawTextTrimmed(rect.min[0] + pad, y, rect.width() - pad * 2.0, help_md, self.theme.colors.text_secondary);
    }

    if (self.package_manager_modal_notice) |notice| {
        self.drawTextTrimmed(rect.min[0] + pad, rect.max[1] - button_h * 2.2 - layout.row_gap, rect.width() - pad * 2.0, notice, self.theme.colors.text_secondary);
    }

    const button_gap = @max(layout.row_gap, 8.0 * self.ui_scale);
    const button_y = rect.max[1] - button_h;
    const action_w = @max(1.0, (rect.width() - pad * 2.0 - button_gap * 3.0) / 4.0);
    const actions_disabled = self.connection_state != .connected;

    if (self.drawButtonWidget(
        Rect.fromXYWH(rect.min[0] + pad, button_y, action_w, button_h),
        "Update",
        .{ .variant = .secondary, .disabled = actions_disabled },
    )) {
        self.packageManagerUpdateSelected(false);
    }
    if (self.drawButtonWidget(
        Rect.fromXYWH(rect.min[0] + pad + (action_w + button_gap), button_y, action_w, button_h),
        "Update + Switch",
        .{ .variant = .primary, .disabled = actions_disabled },
    )) {
        self.packageManagerUpdateSelected(true);
    }
    if (self.drawButtonWidget(
        Rect.fromXYWH(rect.min[0] + pad + (action_w + button_gap) * 2.0, button_y, action_w, button_h),
        "Rollback",
        .{ .variant = .secondary, .disabled = actions_disabled },
    )) {
        self.packageManagerRollbackSelected();
    }
    if (self.drawButtonWidget(
        Rect.fromXYWH(rect.min[0] + pad + (action_w + button_gap) * 3.0, button_y, action_w, button_h),
        if (entry.enabled) "Disable" else "Enable",
        .{ .variant = .secondary, .disabled = actions_disabled },
    )) {
        self.packageManagerToggleSelectedEnabled();
    }
}
