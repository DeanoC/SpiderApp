const std = @import("std");
const tui = @import("../tui.zig");
const server = @import("../commands/server.zig");
const local_node = @import("../commands/local_node.zig");

pub fn run(allocator: std.mem.Allocator) !void {
    const stdout = std.fs.File.stdout().deprecatedWriter();
    tui.writeAnsi(stdout, tui.BOLD ++ tui.BLUE);
    try stdout.writeAll("\n╔══════════════════════════════════════╗\n");
    try stdout.writeAll("║        Spider Linux Home             ║\n");
    try stdout.writeAll("╚══════════════════════════════════════╝\n");
    tui.writeAnsi(stdout, tui.RESET);
    tui.printInfo("Choose what this Linux machine should do first.");
    try stdout.writeAll("\n");
    try stdout.writeAll("  1. Host Spiderweb Here       Run the server on this machine\n");
    try stdout.writeAll("  2. Connect This Linux Machine  Add this machine to another Spiderweb\n");
    try stdout.writeAll("  3. Status / Repair           Check what is installed and what needs attention\n");

    const options = [_][]const u8{
        "Host Spiderweb Here",
        "Connect This Linux Machine",
        "Status / Repair",
    };

    const choice = try tui.select(allocator, "Linux setup", &options);
    switch (choice) {
        0 => try server.runInstallWizard(allocator),
        1 => try local_node.runConnectWizard(allocator),
        2 => try printStatusRepair(allocator),
        else => unreachable,
    }
}

fn printStatusRepair(allocator: std.mem.Allocator) !void {
    const stdout = std.fs.File.stdout().deprecatedWriter();
    try stdout.writeAll("\n");
    tui.printStep(1, 2, "Spiderweb server");
    try server.executeServerStatus(allocator, .{}, .{
        .noun = .server,
        .verb = .status,
        .args = &.{},
    });
    try stdout.writeAll("\n");
    try server.executeServerDoctor(allocator, .{}, .{
        .noun = .server,
        .verb = .doctor,
        .args = &.{},
    });

    try stdout.writeAll("\n");
    tui.printStep(2, 2, "Linux node");
    try local_node.executeLocalNodeStatus(allocator, .{}, .{
        .noun = .local_node,
        .verb = .status,
        .args = &.{},
    });
}
