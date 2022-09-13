const std = @import("std");
const c = @import("c");

pub fn main() !void {
    const allocator = std.heap.page_allocator;

    const loop = try allocator.create(c.uv_loop_t);
    defer allocator.destroy(loop);

    _ = c.uv_loop_init(loop);
    defer _ = c.uv_loop_close(loop);

    std.debug.print("Now quitting.\n", .{});
    _ = c.uv_run(loop, c.UV_RUN_DEFAULT);
}
