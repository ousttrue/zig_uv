const std = @import("std");
const uv = @import("uv");

pub fn main() void {
    const loop: [*c]uv.uv_loop_t = @ptrCast(@alignCast(std.c.malloc(@sizeOf(uv.uv_loop_t)) orelse @panic("malloc[")));
    _ = uv.uv_loop_init(loop);

    std.debug.print("Now quitting.\n", .{});
    _ = uv.uv_run(loop, uv.UV_RUN_DEFAULT);

    _ = uv.uv_loop_close(loop);
    std.c.free(loop);
}
