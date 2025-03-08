const std = @import("std");
// const uv = @import("uv");
const uv = @import("translated");

var open_req = uv.uv_fs_t{};
var read_req = uv.uv_fs_t{};
var write_req = uv.uv_fs_t{};

var buffer: [1024]u8 = undefined;

var iov = uv.uv_buf_t{};

export fn on_write(_req: *anyopaque) void {
    const req: [*c]uv.uv_fs_t = @ptrCast(@alignCast(_req));
    if (req.*.result < 0) {
        std.debug.print("Write error: {s}\n", .{uv.uv_strerror(@intCast(req.*.result))});
    } else {
        _ = uv.uv_fs_read(
            uv.uv_default_loop(),
            &read_req,
            @intCast(open_req.result),
            &iov,
            1,
            -1,
            on_read,
        );
    }
}

export fn on_read(_req: *anyopaque) void {
    const req: [*c]uv.uv_fs_t = @ptrCast(@alignCast(_req));
    if (req.*.result < 0) {
        std.debug.print("Read error: {s}\n", .{uv.uv_strerror(@intCast(req.*.result))});
    } else if (req.*.result == 0) {
        var close_req: uv.uv_fs_t = undefined;
        // synchronous
        _ = uv.uv_fs_close(uv.uv_default_loop(), &close_req, @intCast(open_req.result), null);
    } else if (req.*.result > 0) {
        iov.len = @intCast(req.*.result);
        _ = uv.uv_fs_write(uv.uv_default_loop(), &write_req, 1, &iov, 1, -1, on_write);
    }
}

export fn on_open(_req: *anyopaque) void {
    const req: [*c]uv.uv_fs_t = @ptrCast(@alignCast(_req));
    // The request passed to the callback is the same as the one the call setup
    // function was passed.
    std.debug.assert(req == &open_req);
    if (req.*.result >= 0) {
        iov = uv.uv_buf_init(&buffer[0], @sizeOf(@TypeOf(buffer)));
        _ = uv.uv_fs_read(
            uv.uv_default_loop(),
            &read_req,
            @intCast(req.*.result),
            &iov,
            1,
            -1,
            on_read,
        );
    } else {
        std.debug.print("error opening file: {s}\n", .{uv.uv_strerror(@intCast(req.*.result))});
    }
}

pub fn main() void {
    _ = uv.uv_fs_open(
        uv.uv_default_loop(),
        &open_req,
        std.os.argv[1],
        uv.O_RDONLY,
        0,
        on_open,
    );
    _ = uv.uv_run(uv.uv_default_loop(), uv.UV_RUN_DEFAULT);

    _ = uv.uv_fs_req_cleanup(&open_req);
    _ = uv.uv_fs_req_cleanup(&read_req);
    _ = uv.uv_fs_req_cleanup(&write_req);
}
