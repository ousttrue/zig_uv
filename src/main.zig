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

const message = "  Hello TTY  ";
var tty: c.uv_tty_t = undefined;
var write_req: c.uv_write_t = undefined;
var tick: c.uv_timer_t = undefined;
var width: c_int = undefined;
var height: c_int = undefined;
var pos: c_int = 0;
var signal: c.uv_signal_t = undefined;

fn update(req: [*c]c.uv_timer_t) callconv(.C) void {
    _ = req;

    var data: [500]u8 = undefined;

    uvWrite(&write_req, &tty, std.fmt.bufPrint(
        &data,
        "\x1B[2J\x1B[H\x1B[{}B\x1B[{}C\x1B[42;37m{s}",
        .{ pos, @divTrunc(width - message.len, @as(c_int, 2)), message },
    ) catch unreachable) catch unreachable;

    pos += 1;
    if (pos > height) {
        _ = c.uv_timer_stop(&tick);
        _ = c.uv_signal_stop(&signal);
    }
}

fn resize(handle: [*c]c.uv_signal_t, signum: c_int) callconv(.C) void {
    _ = handle;
    if (signum == c.SIGWINCH) {
        if (c.uv_tty_get_winsize(&tty, &width, &height) != 0) {
            std.debug.print("Could not get TTY information\n", .{});
            return;
        }
    }
}

pub fn main() !void {
    const loop = c.uv_default_loop();

    _ = c.uv_tty_init(loop, &tty, 1, 0);
    _ = c.uv_tty_set_mode(&tty, 0);
    defer _ = c.uv_tty_reset_mode();

    if (c.uv_tty_get_winsize(&tty, &width, &height) != 0) {
        std.debug.print("Could not get TTY information\n", .{});
        return;
    }

    std.debug.print("Width {}, height {}\n", .{ width, height });

    _ = c.uv_signal_init(loop, &signal);
    _ = c.uv_signal_start(&signal, resize, c.SIGWINCH);

    _ = c.uv_timer_init(loop, &tick);
    _ = c.uv_timer_start(&tick, update, 200, 200);

    _ = c.uv_run(loop, c.UV_RUN_DEFAULT);
}
