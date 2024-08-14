const std = @import("std");
const uv = @import("uv");

var counter: i64 = 0;

export fn idle_cb(_: [*c]uv.uv_idle_t) void {
    std.debug.print("Idle callback\n", .{});
    counter += 1;

    if (counter >= 5) {
        _ = uv.uv_stop(uv.uv_default_loop());
        std.debug.print("uv_stop() called\n", .{});
    }
}

export fn prep_cb(_: [*c]uv.uv_prepare_t) void {
    std.debug.print("Prep callback\n", .{});
}

pub fn main() void {
    var idler = uv.uv_idle_t{};
    var prep = uv.uv_prepare_t{};

    _ = uv.uv_idle_init(uv.uv_default_loop(), &idler);
    _ = uv.uv_idle_start(&idler, idle_cb);

    _ = uv.uv_prepare_init(uv.uv_default_loop(), &prep);
    _ = uv.uv_prepare_start(&prep, prep_cb);

    _ = uv.uv_run(uv.uv_default_loop(), uv.UV_RUN_DEFAULT);
}
