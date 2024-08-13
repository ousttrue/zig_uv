const std = @import("std");
const uv = @import("uv");

var counter: i64 = 0;

export fn wait_for_a_while(handle: [*c]uv.uv_idle_t) void {
    counter += 1;

    if (counter >= 10e6) {
        _ = uv.uv_idle_stop(handle);
    }
}

pub fn main() void {
    var idler: uv.uv_idle_t = undefined;

    _ = uv.uv_idle_init(uv.uv_default_loop(), &idler);
    _ = uv.uv_idle_start(&idler, wait_for_a_while);

    std.debug.print("Idling...\n", .{});
    _ = uv.uv_run(uv.uv_default_loop(), uv.UV_RUN_DEFAULT);

    _ = uv.uv_loop_close(uv.uv_default_loop());
}
