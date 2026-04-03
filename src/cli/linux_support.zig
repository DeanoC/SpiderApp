const std = @import("std");
const builtin = @import("builtin");

pub const ServiceScope = enum {
    system,
    user,
};

pub const CommandResult = struct {
    stdout: []u8,
    stderr: []u8,
    term: std.process.Child.Term,

    pub fn deinit(self: *CommandResult, allocator: std.mem.Allocator) void {
        allocator.free(self.stdout);
        allocator.free(self.stderr);
        self.* = undefined;
    }

    pub fn ok(self: CommandResult) bool {
        return switch (self.term) {
            .Exited => |code| code == 0,
            else => false,
        };
    }

    pub fn summary(self: CommandResult, fallback: []const u8) []const u8 {
        const stdout_text = std.mem.trim(u8, self.stdout, " \t\r\n");
        if (stdout_text.len > 0) return stdout_text;
        const stderr_text = std.mem.trim(u8, self.stderr, " \t\r\n");
        if (stderr_text.len > 0) return stderr_text;
        return fallback;
    }
};

pub const ServiceUser = struct {
    name: []u8,
    home: []u8,
    config_home: []u8,
    scope: ServiceScope,

    pub fn deinit(self: *ServiceUser, allocator: std.mem.Allocator) void {
        allocator.free(self.name);
        allocator.free(self.home);
        allocator.free(self.config_home);
        self.* = undefined;
    }
};

pub fn ensureLinuxSupported() !void {
    if (builtin.os.tag != .linux) return error.UnsupportedPlatform;
}

pub fn pathExists(path: []const u8) bool {
    if (std.fs.path.isAbsolute(path)) {
        std.fs.accessAbsolute(path, .{}) catch return false;
        return true;
    }
    std.fs.cwd().access(path, .{}) catch return false;
    return true;
}

pub fn ensureParentPath(path: []const u8) !void {
    const parent = std.fs.path.dirname(path) orelse return;
    if (parent.len == 0) return;

    if (std.fs.path.isAbsolute(parent)) {
        var root = try std.fs.openDirAbsolute("/", .{});
        defer root.close();
        const relative = std.mem.trimLeft(u8, parent, "/");
        if (relative.len == 0) return;
        try root.makePath(relative);
        return;
    }

    try std.fs.cwd().makePath(parent);
}

pub fn makePathAny(path: []const u8) !void {
    if (path.len == 0) return;
    if (std.fs.path.isAbsolute(path)) {
        var root = try std.fs.openDirAbsolute("/", .{});
        defer root.close();
        const relative = std.mem.trimLeft(u8, path, "/");
        if (relative.len == 0) return;
        try root.makePath(relative);
        return;
    }
    try std.fs.cwd().makePath(path);
}

pub fn writeFileAny(path: []const u8, payload: []const u8) !void {
    try ensureParentPath(path);
    if (std.fs.path.isAbsolute(path)) {
        var root = try std.fs.openDirAbsolute("/", .{});
        defer root.close();
        const relative = std.mem.trimLeft(u8, path, "/");
        if (relative.len == 0) return error.InvalidArguments;
        try root.writeFile(.{ .sub_path = relative, .data = payload });
        return;
    }
    try std.fs.cwd().writeFile(.{ .sub_path = path, .data = payload });
}

pub fn readFileAllocAny(
    allocator: std.mem.Allocator,
    path: []const u8,
    max_bytes: usize,
) ![]u8 {
    if (std.fs.path.isAbsolute(path)) {
        var file = try std.fs.openFileAbsolute(path, .{});
        defer file.close();
        return file.readToEndAlloc(allocator, max_bytes);
    }
    var file = try std.fs.cwd().openFile(path, .{});
    defer file.close();
    return file.readToEndAlloc(allocator, max_bytes);
}

fn resolveUserNameFromEnv(allocator: std.mem.Allocator) ![]u8 {
    if (std.process.getEnvVarOwned(allocator, "SUDO_USER") catch null) |value| {
        if (value.len > 0) return value;
        allocator.free(value);
    }
    if (std.process.getEnvVarOwned(allocator, "USER") catch null) |value| {
        if (value.len > 0) return value;
        allocator.free(value);
    }

    var result = try runCommandCapture(allocator, &.{ "id", "-un" });
    defer result.deinit(allocator);
    if (!result.ok()) return error.CommandFailed;
    return allocator.dupe(u8, std.mem.trim(u8, result.stdout, " \t\r\n"));
}

fn resolveHomeForUser(allocator: std.mem.Allocator, user_name: []const u8) ![]u8 {
    const current_user = std.process.getEnvVarOwned(allocator, "USER") catch null;
    defer if (current_user) |value| allocator.free(value);
    if (current_user) |value| {
        if (std.mem.eql(u8, value, user_name)) {
            if (std.process.getEnvVarOwned(allocator, "HOME") catch null) |home| {
                if (home.len > 0) return home;
                allocator.free(home);
            }
        }
    }

    var result = try runCommandCapture(allocator, &.{ "getent", "passwd", user_name });
    defer result.deinit(allocator);
    if (!result.ok()) return error.CommandFailed;
    const line = std.mem.trim(u8, result.stdout, " \t\r\n");
    var fields = std.mem.splitScalar(u8, line, ':');
    var index: usize = 0;
    while (fields.next()) |field| : (index += 1) {
        if (index == 5 and field.len > 0) return allocator.dupe(u8, field);
    }
    return error.CommandFailed;
}

pub fn resolveServiceUser(allocator: std.mem.Allocator) !ServiceUser {
    try ensureLinuxSupported();
    const user_name = try resolveUserNameFromEnv(allocator);
    errdefer allocator.free(user_name);
    const home = try resolveHomeForUser(allocator, user_name);
    errdefer allocator.free(home);
    const config_home = try std.fs.path.join(allocator, &.{ home, ".config" });
    errdefer allocator.free(config_home);
    return .{
        .name = user_name,
        .home = home,
        .config_home = config_home,
        .scope = if (std.posix.getuid() == 0) .system else .user,
    };
}

pub fn resolveSpiderConfigDir(allocator: std.mem.Allocator, user: ServiceUser) ![]u8 {
    return std.fs.path.join(allocator, &.{ user.config_home, "spider" });
}

pub fn resolveSpiderwebConfigPath(allocator: std.mem.Allocator, user: ServiceUser) ![]u8 {
    return std.fs.path.join(allocator, &.{ user.config_home, "spiderweb", "config.json" });
}

pub fn resolveLinuxNodeConfigPath(allocator: std.mem.Allocator, user: ServiceUser) ![]u8 {
    return std.fs.path.join(allocator, &.{ user.config_home, "spider", "linux-node.json" });
}

pub fn resolveLinuxNodeStatePath(allocator: std.mem.Allocator, user: ServiceUser) ![]u8 {
    return std.fs.path.join(allocator, &.{ user.config_home, "spider", "linux-node-state.json" });
}

pub fn resolveSystemdUnitPath(
    allocator: std.mem.Allocator,
    user: ServiceUser,
    unit_name: []const u8,
) ![]u8 {
    return switch (user.scope) {
        .system => std.fs.path.join(allocator, &.{ "/etc", "systemd", "system", unit_name }),
        .user => std.fs.path.join(allocator, &.{ user.home, ".config", "systemd", "user", unit_name }),
    };
}

pub fn resolveInstalledBinary(allocator: std.mem.Allocator, binary_name: []const u8) ![]u8 {
    const self_exe = try std.fs.selfExePathAlloc(allocator);
    defer allocator.free(self_exe);
    const self_dir = std.fs.path.dirname(self_exe) orelse ".";
    const sibling = try std.fs.path.join(allocator, &.{ self_dir, binary_name });
    errdefer allocator.free(sibling);
    if (pathExists(sibling)) return sibling;
    allocator.free(sibling);
    return resolveBinaryOnPath(allocator, binary_name);
}

pub fn resolveBinaryOnPath(allocator: std.mem.Allocator, binary_name: []const u8) ![]u8 {
    if (std.mem.indexOfScalar(u8, binary_name, '/')) |_| return allocator.dupe(u8, binary_name);

    const path_env = std.process.getEnvVarOwned(allocator, "PATH") catch return allocator.dupe(u8, binary_name);
    defer allocator.free(path_env);
    var it = std.mem.splitScalar(u8, path_env, ':');
    while (it.next()) |segment| {
        if (segment.len == 0) continue;
        const candidate = try std.fs.path.join(allocator, &.{ segment, binary_name });
        errdefer allocator.free(candidate);
        if (pathExists(candidate)) return candidate;
        allocator.free(candidate);
    }
    return allocator.dupe(u8, binary_name);
}

pub fn runCommandCapture(
    allocator: std.mem.Allocator,
    argv: []const []const u8,
) !CommandResult {
    const result = try std.process.Child.run(.{
        .allocator = allocator,
        .argv = argv,
        .max_output_bytes = 256 * 1024,
    });
    return .{
        .stdout = result.stdout,
        .stderr = result.stderr,
        .term = result.term,
    };
}

fn privilegeDropTool(allocator: std.mem.Allocator) ![]const u8 {
    const sudo_path = try resolveBinaryOnPath(allocator, "sudo");
    defer allocator.free(sudo_path);
    if (pathExists(sudo_path)) return "sudo";
    const runuser_path = try resolveBinaryOnPath(allocator, "runuser");
    defer allocator.free(runuser_path);
    if (pathExists(runuser_path)) return "runuser";
    return error.CommandFailed;
}

pub fn runCommandAsServiceUser(
    allocator: std.mem.Allocator,
    user: ServiceUser,
    argv: []const []const u8,
) !CommandResult {
    if (std.posix.getuid() != 0) return runCommandCapture(allocator, argv);
    if (std.mem.eql(u8, user.name, "root")) return runCommandCapture(allocator, argv);

    const drop_tool = try privilegeDropTool(allocator);
    var cmd = std.ArrayListUnmanaged([]const u8){};
    defer cmd.deinit(allocator);
    if (std.mem.eql(u8, drop_tool, "sudo")) {
        try cmd.appendSlice(allocator, &.{ "sudo", "-u", user.name, "-H", "--" });
    } else {
        try cmd.appendSlice(allocator, &.{ "runuser", "-u", user.name, "--" });
    }
    try cmd.appendSlice(allocator, argv);
    return runCommandCapture(allocator, cmd.items);
}

pub fn ensureOwnedByServiceUser(
    allocator: std.mem.Allocator,
    user: ServiceUser,
    path: []const u8,
) !void {
    if (std.posix.getuid() != 0) return;
    if (std.mem.eql(u8, user.name, "root")) return;
    if (!pathExists(path)) return;

    var result = try runCommandCapture(allocator, &.{ "chown", "-R", user.name, path });
    defer result.deinit(allocator);
    if (!result.ok()) return error.CommandFailed;
}

pub fn systemctlAction(
    allocator: std.mem.Allocator,
    user: ServiceUser,
    action_args: []const []const u8,
) !CommandResult {
    var argv = std.ArrayListUnmanaged([]const u8){};
    defer argv.deinit(allocator);
    try argv.append(allocator, "systemctl");
    if (user.scope == .user) try argv.append(allocator, "--user");
    try argv.appendSlice(allocator, action_args);
    return runCommandCapture(allocator, argv.items);
}

pub fn systemdState(
    allocator: std.mem.Allocator,
    user: ServiceUser,
    unit_name: []const u8,
) !struct { installed: bool, enabled: bool, active: bool } {
    const unit_path = try resolveSystemdUnitPath(allocator, user, unit_name);
    defer allocator.free(unit_path);
    const installed = pathExists(unit_path);

    var enabled_result = try systemctlAction(allocator, user, &.{ "is-enabled", unit_name });
    defer enabled_result.deinit(allocator);
    var active_result = try systemctlAction(allocator, user, &.{ "is-active", unit_name });
    defer active_result.deinit(allocator);

    const enabled_text = std.mem.trim(u8, enabled_result.stdout, " \t\r\n");
    const active_text = std.mem.trim(u8, active_result.stdout, " \t\r\n");

    return .{
        .installed = installed,
        .enabled = installed and std.mem.eql(u8, enabled_text, "enabled"),
        .active = installed and std.mem.eql(u8, active_text, "active"),
    };
}

pub fn serverBindAllowsRemoteConnections(bind: []const u8) bool {
    const trimmed = std.mem.trim(u8, bind, " \t\r\n");
    if (trimmed.len == 0) return false;
    return !std.mem.eql(u8, trimmed, "127.0.0.1") and
        !std.mem.eql(u8, trimmed, "localhost") and
        !std.mem.eql(u8, trimmed, "::1");
}
