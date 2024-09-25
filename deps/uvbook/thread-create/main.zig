const std = @import("std");
const uv = @import("uv");

export fn hare(arg: ?*anyopaque) void {
    var tracklen = @as(*c_int, @ptrCast(@alignCast(arg.?))).*;
    while (tracklen != 0) : (tracklen -= 1) {
        _ = uv.uv_sleep(1000);
        std.debug.print("Hare ran another step\n", .{});
    }
    std.debug.print("Hare done running!\n", .{});
}

export fn tortoise(arg: ?*anyopaque) void {
    var tracklen = @as(*c_int, @ptrCast(@alignCast(arg.?))).*;
    while (tracklen != 0) : (tracklen -= 1) {
        std.debug.print("Tortoise ran another step\n", .{});
        _ = uv.uv_sleep(3000);
    }
    std.debug.print("Tortoise done running!\n", .{});
}

pub fn main() void {
    var tracklen: c_int = 10;
    var hare_id: uv.uv_thread_t = undefined;
    var tortoise_id: uv.uv_thread_t = undefined;
    _ = uv.uv_thread_create(&hare_id, hare, &tracklen);
    _ = uv.uv_thread_create(&tortoise_id, tortoise, &tracklen);

    _ = uv.uv_thread_join(&hare_id);
    _ = uv.uv_thread_join(&tortoise_id);
}
