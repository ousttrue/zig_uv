const std = @import("std");
// const uv = @import("uv");
const uv = @import("translated");

const write_req_t = extern struct {
    req: uv.uv_write_t = .{},
    buf: uv.uv_buf_t = .{},
};

var loop: *uv.uv_loop_t = undefined;
var stdin_pipe: uv.uv_pipe_t = undefined;
var stdout_pipe: uv.uv_pipe_t = undefined;
var file_pipe: uv.uv_pipe_t = undefined;

export fn alloc_buffer(_: [*c]uv.uv_handle_t, suggested_size: usize, buf: [*c]uv.uv_buf_t) void {
    const new_buffer: [*c]u8 = @ptrCast(std.c.malloc(suggested_size));
    buf.* = uv.uv_buf_init(new_buffer, @intCast(suggested_size));
}

fn free_write_req(req: [*c]uv.uv_write_t) void {
    const wr = @as(*write_req_t, @ptrCast(req));
    std.c.free(wr.*.buf.base);
    std.c.free(wr);
}

export fn on_stdout_write(_req: *anyopaque, _: c_int) void {
    const req: [*c]uv.uv_write_t = @ptrCast(@alignCast(_req));
    free_write_req(req);
}

export fn on_file_write(_req: *anyopaque, _: c_int) void {
    const req: [*c]uv.uv_write_t = @ptrCast(@alignCast(_req));
    free_write_req(req);
}

fn write_data(dest: [*c]uv.uv_stream_t, size: usize, buf: uv.uv_buf_t, cb: uv.uv_write_cb) void {
    const req: *write_req_t = @ptrCast(@alignCast(std.c.malloc(@sizeOf(write_req_t)) orelse @panic("malloc")));
    req.buf = uv.uv_buf_init(@ptrCast(std.c.malloc(size) orelse @panic("malloc")), @intCast(size));
    @memcpy(req.buf.base[0..size], buf.base[0..size]);
    _ = uv.uv_write(@ptrCast(req), dest, &req.buf, 1, cb);
}

export fn read_stdin(_: *anyopaque, nread: isize, buf: [*c]const uv.uv_buf_t) void {
    if (nread < 0) {
        if (nread == uv.UV_EOF) {
            // end of file
            _ = uv.uv_close(@ptrCast(&stdin_pipe), null);
            _ = uv.uv_close(@ptrCast(&stdout_pipe), null);
            _ = uv.uv_close(@ptrCast(&file_pipe), null);
        }
    } else if (nread > 0) {
        write_data(@ptrCast(&stdout_pipe), @intCast(nread), buf.*, on_stdout_write);
        write_data(@ptrCast(&file_pipe), @intCast(nread), buf.*, on_file_write);
    }

    // OK to free buffer as write_data copies it.
    if (buf.*.base != 0)
        std.c.free(buf.*.base);
}

pub fn main() void {
    loop = uv.uv_default_loop();

    _ = uv.uv_pipe_init(loop, &stdin_pipe, 0);
    _ = uv.uv_pipe_open(&stdin_pipe, 0);

    _ = uv.uv_pipe_init(loop, &stdout_pipe, 0);
    _ = uv.uv_pipe_open(&stdout_pipe, 1);

    var file_req: uv.uv_fs_t = undefined;
    const fd = uv.uv_fs_open(loop, &file_req, std.os.argv[1], uv.O_CREAT | uv.O_RDWR, 0o0644, null);
    _ = uv.uv_pipe_init(loop, &file_pipe, 0);
    _ = uv.uv_pipe_open(&file_pipe, fd);

    _ = uv.uv_read_start(@ptrCast(&stdin_pipe), alloc_buffer, read_stdin);

    _ = uv.uv_run(loop, uv.UV_RUN_DEFAULT);
}
