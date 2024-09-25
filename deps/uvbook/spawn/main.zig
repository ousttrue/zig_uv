const std = @import("std");
const uv = @import("uv");

var loop: *uv.uv_loop_t = undefined;
var child_req = uv.uv_process_t{};
var options = uv.uv_process_options_t{};

export fn on_exit(req: [*c]uv.uv_process_t, exit_status: i64, term_signal: c_int) void {
    std.debug.print("Process exited with status {}, signal {}\n", .{ exit_status, term_signal });
    _ = uv.uv_close(@ptrCast(req), null);
}

pub fn main() void {
    loop = uv.uv_default_loop();

    var args = [_][*c]const u8{
        "mkdir".ptr,
        "test-dir".ptr,
        null,
    };

    options.exit_cb = on_exit;
    options.file = "mkdir";
    options.args = @ptrCast(&args[0]);

    const r = uv.uv_spawn(loop, &child_req, &options);
    if (r != 0) {
        std.debug.print("{s}\n", .{uv.uv_strerror(r)});
        std.c.exit(1);
    } else {
        std.debug.print("Launched process with ID {}\n", .{child_req.pid});
    }

    _ = uv.uv_run(loop, uv.UV_RUN_DEFAULT);
}
