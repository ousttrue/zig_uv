const std = @import("std");
const c = @import("c");

fn uvWrite(req: *c.uv_write_t, stream: *anyopaque, msg: []const u8) !void {
    var buf: c.uv_buf_t = undefined;
    buf.base = @intToPtr(*u8, @ptrToInt(&msg[0]));
    buf.len = @intCast(c_ulong, msg.len);

    _ = c.uv_write(
        req,
        @ptrCast(*c.uv_stream_t, @alignCast(@alignOf(c.uv_stream_t), stream)),
        &buf,
        1,
        null,
    );
}

pub fn main() !void {
    const loop = c.uv_default_loop();
    var tty: c.uv_tty_t = undefined;
    _ = c.uv_tty_init(loop, &tty, 1, 0);
    _ = c.uv_tty_set_mode(&tty, 0);
    defer _ = c.uv_tty_reset_mode();

    if (c.uv_guess_handle(1) == c.UV_TTY) {
        var req0: c.uv_write_t = undefined;
        try uvWrite(&req0, &tty, "\x1B[41;37m");
    }
    var req1: c.uv_write_t = undefined;
    try uvWrite(&req1, &tty, "Hello TTY\n");

    _ = c.uv_run(loop, c.UV_RUN_DEFAULT);
}
