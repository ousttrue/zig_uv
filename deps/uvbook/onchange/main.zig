const std = @import("std");
const uv = @import("uv");

var loop: *uv.uv_loop_t = undefined;
var command: []const u8 = undefined;

export fn run_command(
    handle: [*c]uv.uv_fs_event_t,
    filename: [*c]const u8,
    events: c_int,
    _: c_int,
) void {
    var path: [1024]u8 = undefined;
    var size: usize = 1023;
    // Does not handle error if path is longer than 1023.
    _ = uv.uv_fs_event_getpath(handle, &path[0], &size);
    path[size] = 0;

    std.debug.print("Change detected in {s}: ", .{path});
    if (events & uv.UV_RENAME != 0)
        std.debug.print("renamed", .{});
    if (events & uv.UV_CHANGE != 0)
        std.debug.print("changed", .{});

    if (filename) |file| {
        std.debug.print(" {s}\n", .{file});
    } else {
        std.debug.print("\n", .{});
    }
    // std.ChildProcess.exec(std.heap.page_allocator, &.{command}) catch @panic("exec");

    var child = std.process.Child.init(&.{command}, std.heap.page_allocator);
    _ = child.spawnAndWait() catch @panic("spawnAndWait");
}

pub fn main() void {
    if (std.os.argv.len <= 2) {
        std.debug.print("Usage: {s} <command> <file1> [file2 ...]\n", .{std.os.argv[0]});
        std.c.exit(1);
        unreachable;
    }

    loop = uv.uv_default_loop();
    const p = std.os.argv[1];
    command = p[0..std.mem.len(p)];

    var argc = std.os.argv.len;
    while (argc > 2) : (argc -= 1) {
        std.debug.print("Adding watch on {s}\n", .{std.os.argv[argc]});
        const fs_event_req: *uv.uv_fs_event_t = @ptrCast(@alignCast(std.c.malloc(@sizeOf(uv.uv_fs_event_t))));
        _ = uv.uv_fs_event_init(loop, fs_event_req);
        // The recursive flag watches subdirectories too.
        _ = uv.uv_fs_event_start(fs_event_req, run_command, std.os.argv[argc], uv.UV_FS_EVENT_RECURSIVE);
    }

    _ = uv.uv_run(loop, uv.UV_RUN_DEFAULT);
}
