const std = @import("std");
const uv = @import("uv");

// fn castStream(p: *anyopaque) *c.uv_stream_t {
//     return @ptrCast(*c.uv_stream_t, @alignCast(@alignOf(c.uv_stream_t), p));
// }

// fn uvWrite(req: *c.uv_write_t, stream: *anyopaque, msg: []const u8) !void {
//     var buf: c.uv_buf_t = undefined;
//     buf.base = @intToPtr(*u8, @ptrToInt(&msg[0]));
//     buf.len = @intCast(c_ulong, msg.len);
//
//     _ = c.uv_write(
//         req,
//         castStream(stream),
//         &buf,
//         1,
//         null,
//     );
// }

// const message = "  Hello TTY  ";
var allocator: std.mem.Allocator = undefined;
var tty_out: uv.Tty = undefined;
// var write_req: c.uv_write_t = undefined;
// var tty_in: c.uv_tty_t = undefined;
// var tick: c.uv_timer_t = undefined;
// var width: c_int = undefined;
// var height: c_int = undefined;
// var pos: c_int = 0;
// var signal: c.uv_signal_t = undefined;

// fn update(req: [*c]c.uv_timer_t) callconv(.C) void {
//     _ = req;
//
//     var data: [500]u8 = undefined;
//
//     uvWrite(&write_req, &tty_out, std.fmt.bufPrint(
//         &data,
//         "\x1B[2J\x1B[H\x1B[{}B\x1B[{}C\x1B[42;37m{s}",
//         .{ pos, @divTrunc(width - message.len, @as(c_int, 2)), message },
//     ) catch unreachable) catch unreachable;
//
//     pos += 1;
//     if (pos > height) {
//         _ = c.uv_read_stop(castStream(&tty_in));
//         _ = c.uv_timer_stop(&tick);
//         _ = c.uv_signal_stop(&signal);
//     }
// }

// fn resize(handle: [*c]c.uv_signal_t, signum: c_int) callconv(.C) void {
//     _ = handle;
//     if (signum == c.SIGWINCH) {
//         if (c.uv_tty_get_winsize(&tty_out, &width, &height) != 0) {
//             std.debug.print("Could not get TTY information\n", .{});
//             return;
//         }
//     }
// }

// fn alloc_cb(handle: [*c]c.uv_handle_t, size: usize, buf: [*c]c.uv_buf_t) callconv(.C) void {
//     _ = handle;
//     _ = size;
//     buf.* = c.uv_buf_init(@ptrCast([*c]u8, c.malloc(size)), @intCast(c_uint, size));
// }

// fn read_cb(handle: [*c]c.uv_stream_t, size: isize, buf: [*c]const c.uv_buf_t) callconv(.C) void {
//     _ = handle;
//     _ = size;
//     _ = buf;
//     // // printf("read_cb(%p, %d)\n", handle, (int)size);
//     // if (size < 0) {
//     //     @panic("-");
//     //     // c.uv_close((uv_handle_t *)handle, close_cb); /* We MUST close the handle on error */
//     // }
//     // c.free(buf.*.base);
// }

pub fn main() !void {
    allocator = std.heap.page_allocator;
    const loop = uv.uv_default_loop();

    // _ = uv.uv_tty_init(loop, &tty_out, 1, 0);
    // _ = c.uv_tty_set_mode(&tty_out, 0);
    // defer _ = c.uv_tty_reset_mode();
    //
    // if (c.uv_tty_get_winsize(&tty_out, &width, &height) != 0) {
    //     std.debug.print("Could not get TTY information\n", .{});
    //     return;
    // }
    //
    // std.debug.print("Width {}, height {}\n", .{ width, height });
    //
    // _ = c.uv_tty_init(loop, &tty_in, 0, 1);
    // _ = c.uv_tty_set_mode(&tty_in, c.UV_TTY_MODE_RAW);
    // _ = c.uv_read_start(castStream(&tty_in), alloc_cb, read_cb);
    //
    // _ = c.uv_signal_init(loop, &signal);
    // _ = c.uv_signal_start(&signal, resize, c.SIGWINCH);
    //
    // _ = c.uv_timer_init(loop, &tick);
    // _ = c.uv_timer_start(&tick, update, 200, 200);

    std.debug.print("begin\n", .{});
    _ = uv.uv_run(loop, 0);
    std.debug.print("end\n", .{});
}
