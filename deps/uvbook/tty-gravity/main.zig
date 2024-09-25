const std = @import("std");
const uv = @import("translated");

var loop: *uv.uv_loop_t = undefined;
var tty = uv.uv_tty_t{};
var tick = uv.uv_timer_t{};
var write_req = uv.uv_write_t{};
var width: c_int = undefined;
var height: c_int = undefined;
var pos: i32 = 0;
const message: []const u8 = "  Hello TTY  ";

export fn update(_: [*c]uv.uv_timer_t) void {
    var data: [500]u8 = undefined;

    var buf = uv.uv_buf_t{};
    buf.base = &data[0];
    const formated = std.fmt.bufPrintZ(
        &data,
        "\x1b[2J\x1b[H\x1b[{}B\x1b[{}C\x1b[42;37m{s}",
        .{ pos, @divTrunc(@as(usize, @intCast(width)) - message.len, 2), message },
    ) catch @panic("bufPrintZ");
    buf.len = @intCast(formated.len);
    _ = uv.uv_write(&write_req, @ptrCast(&tty), &buf, 1, null);

    pos += 1;
    if (pos > height) {
        _ = uv.uv_tty_reset_mode();
        _ = uv.uv_timer_stop(&tick);
    }
}

pub fn main() void {
    loop = uv.uv_default_loop();

    _ = uv.uv_tty_init(loop, &tty, uv.STDOUT_FILENO, 0);
    _ = uv.uv_tty_set_mode(&tty, 0);

    if (uv.uv_tty_get_winsize(&tty, &width, &height) != 0) {
        std.debug.print("Could not get TTY information\n", .{});
        _ = uv.uv_tty_reset_mode();
        std.c.exit(1);
        unreachable;
    }

    std.debug.print("Width {}, height {}\n", .{ width, height });
    _ = uv.uv_timer_init(loop, &tick);
    _ = uv.uv_timer_start(&tick, update, 200, 200);
    _ = uv.uv_run(loop, uv.UV_RUN_DEFAULT);
}
