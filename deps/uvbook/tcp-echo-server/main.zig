const std = @import("std");
const uv = @import("translated");

const DEFAULT_PORT = 7000;
const DEFAULT_BACKLOG = 128;

var loop: *uv.uv_loop_t = undefined;

var addr = uv.sockaddr_in{};

const write_req_t = extern struct {
    req: uv.uv_write_t = .{},
    buf: uv.uv_buf_t = .{},
};

fn free_write_req(req: *uv.uv_write_t) void {
    const wr: *write_req_t = @ptrCast(req);
    std.c.free(wr.buf.base);
    std.c.free(wr);
}

export fn alloc_buffer(_: [*c]uv.uv_handle_t, suggested_size: usize, buf: [*c]uv.uv_buf_t) void {
    buf.*.base = @ptrCast(std.c.malloc(suggested_size) orelse @panic("malloc"));
    buf.*.len = @intCast(suggested_size);
}

export fn on_close(handle: [*c]uv.uv_handle_t) void {
    std.c.free(handle);
}

export fn echo_write(_req: *anyopaque, status: c_int) void {
    const req: [*c]uv.uv_write_t = @ptrCast(@alignCast(_req));
    if (status != 0) {
        std.debug.print("Write error {s}\n", .{uv.uv_strerror(status)});
    }
    free_write_req(req);
}

export fn echo_read(client: *anyopaque, nread: isize, buf: [*c]const uv.uv_buf_t) void {
    if (nread > 0) {
        const req: *write_req_t = @ptrCast(@alignCast(std.c.malloc(@sizeOf(write_req_t)) orelse @panic("malloc")));
        req.buf = uv.uv_buf_init(buf.*.base, @intCast(nread));
        _ = uv.uv_write(@ptrCast(req), @ptrCast(@alignCast(client)), &req.buf, 1, echo_write);
        return;
    }
    if (nread < 0) {
        if (nread != uv.UV_EOF)
            std.debug.print("Read error {s}\n", .{uv.uv_err_name(@intCast(nread))});
        _ = uv.uv_close(@ptrCast(@alignCast(client)), on_close);
    }

    std.c.free(buf.*.base);
}

export fn on_new_connection(server: [*c]uv.uv_stream_t, status: c_int) void {
    if (status < 0) {
        std.debug.print("New connection error {s}\n", .{uv.uv_strerror(status)});
        return;
    }

    const client: *uv.uv_tcp_t = @ptrCast(@alignCast(std.c.malloc(@sizeOf(uv.uv_tcp_t)) orelse @panic("malloc")));
    _ = uv.uv_tcp_init(loop, client);
    if (uv.uv_accept(server, @ptrCast(client)) == 0) {
        _ = uv.uv_read_start(@ptrCast(client), alloc_buffer, echo_read);
    } else {
        _ = uv.uv_close(@ptrCast(client), on_close);
    }
}

pub fn main() void {
    loop = uv.uv_default_loop();

    var server = uv.uv_tcp_t{};
    _ = uv.uv_tcp_init(loop, &server);

    _ = uv.uv_ip4_addr("0.0.0.0", DEFAULT_PORT, &addr);

    _ = uv.uv_tcp_bind(&server, @ptrCast(&addr), 0);
    const r = uv.uv_listen(@ptrCast(&server), DEFAULT_BACKLOG, on_new_connection);
    if (r != 0) {
        std.debug.print("Listen error {s}\n", .{uv.uv_strerror(r)});
        std.c.exit(1);
        unreachable;
    }
    _ = uv.uv_run(loop, uv.UV_RUN_DEFAULT);
}
