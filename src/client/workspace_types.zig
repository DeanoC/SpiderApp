const std = @import("std");

pub const MountView = struct {
    mount_path: []u8,
    node_id: []u8,
    node_name: ?[]u8 = null,
    fs_url: ?[]u8 = null,
    export_name: []u8,

    pub fn deinit(self: *MountView, allocator: std.mem.Allocator) void {
        allocator.free(self.mount_path);
        allocator.free(self.node_id);
        if (self.node_name) |value| allocator.free(value);
        if (self.fs_url) |value| allocator.free(value);
        allocator.free(self.export_name);
        self.* = undefined;
    }
};

pub const ProjectSummary = struct {
    id: []u8,
    name: []u8,
    vision: []u8,
    status: []u8,
    mount_count: usize,
    created_at_ms: i64,
    updated_at_ms: i64,

    pub fn deinit(self: *ProjectSummary, allocator: std.mem.Allocator) void {
        allocator.free(self.id);
        allocator.free(self.name);
        allocator.free(self.vision);
        allocator.free(self.status);
        self.* = undefined;
    }
};

pub const ProjectDetail = struct {
    id: []u8,
    name: []u8,
    vision: []u8,
    status: []u8,
    created_at_ms: i64,
    updated_at_ms: i64,
    project_token: ?[]u8 = null,
    mounts: std.ArrayListUnmanaged(MountView) = .{},

    pub fn deinit(self: *ProjectDetail, allocator: std.mem.Allocator) void {
        allocator.free(self.id);
        allocator.free(self.name);
        allocator.free(self.vision);
        allocator.free(self.status);
        if (self.project_token) |value| allocator.free(value);
        for (self.mounts.items) |*mount| mount.deinit(allocator);
        self.mounts.deinit(allocator);
        self.* = undefined;
    }
};

pub const NodeInfo = struct {
    node_id: []u8,
    node_name: []u8,
    fs_url: []u8,
    joined_at_ms: i64,
    last_seen_ms: i64,
    lease_expires_at_ms: i64,

    pub fn deinit(self: *NodeInfo, allocator: std.mem.Allocator) void {
        allocator.free(self.node_id);
        allocator.free(self.node_name);
        allocator.free(self.fs_url);
        self.* = undefined;
    }
};

pub const WorkspaceStatus = struct {
    agent_id: []u8,
    project_id: ?[]u8 = null,
    workspace_root: ?[]u8 = null,
    mounts: std.ArrayListUnmanaged(MountView) = .{},

    pub fn deinit(self: *WorkspaceStatus, allocator: std.mem.Allocator) void {
        allocator.free(self.agent_id);
        if (self.project_id) |value| allocator.free(value);
        if (self.workspace_root) |value| allocator.free(value);
        for (self.mounts.items) |*mount| mount.deinit(allocator);
        self.mounts.deinit(allocator);
        self.* = undefined;
    }
};

pub fn deinitProjectList(allocator: std.mem.Allocator, projects: *std.ArrayListUnmanaged(ProjectSummary)) void {
    for (projects.items) |*project| project.deinit(allocator);
    projects.deinit(allocator);
    projects.* = .{};
}

pub fn deinitNodeList(allocator: std.mem.Allocator, nodes: *std.ArrayListUnmanaged(NodeInfo)) void {
    for (nodes.items) |*node| node.deinit(allocator);
    nodes.deinit(allocator);
    nodes.* = .{};
}
