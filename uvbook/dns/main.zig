const std = @import("std");
const uv = @import("uv");

var loop: *uv.uv_loop_t = undefined;

export fn alloc_buffer(_: [*c]uv.uv_handle_t, suggested_size: usize, buf: [*c]uv.uv_buf_t) void {
    buf.*.base = @ptrCast(std.c.malloc(suggested_size) orelse @panic("malloc"));
    buf.*.len = @intCast(suggested_size);
}

export fn on_read(client: [*c]uv.uv_stream_t, nread: isize, buf: [*c]const uv.uv_buf_t) void {
    if (nread < 0) {
        if (nread != uv.UV_EOF)
            std.debug.print("Read error {s}\n", .{uv.uv_err_name(@intCast(nread))});
        _ = uv.uv_close(@ptrCast(client), null);
        std.c.free(buf.*.base);
        std.c.free(client);
        return;
    }

    var data: [*]u8 = @ptrCast(std.c.malloc(@sizeOf(c_char) * (@as(usize, @intCast(nread)) + 1)) orelse @panic("malloc"));
    data[@intCast(nread)] = 0;
    @memcpy(data[0..@intCast(nread)], @as([*]u8, @ptrCast(buf.*.base)));

    std.debug.print("{any}", .{data});
    std.c.free(data);
    std.c.free(buf.*.base);
}

export fn on_connect(req: [*c]uv.uv_connect_t, status: c_int) void {
    if (status < 0) {
        std.debug.print("connect failed error {s}\n", .{uv.uv_err_name(status)});
        std.c.free(req);
        return;
    }

    _ = uv.uv_read_start(req.*.handle, alloc_buffer, on_read);
    std.c.free(req);
}

export fn on_resolved(_: [*c]uv.uv_getaddrinfo_t, status: c_int, res: [*c]uv.addrinfo) void {
    if (status < 0) {
        std.debug.print("getaddrinfo callback error {s}\n", .{uv.uv_err_name(status)});
        return;
    }

    var addr = [1]u8{0} ** 17;
    _ = uv.uv_ip4_name(@ptrCast(@alignCast(res.*.ai_addr)), @ptrCast(&addr[0]), 16);
    std.debug.print("{any}\n", .{addr});

    const connect_req: *uv.uv_connect_t = @ptrCast(@alignCast(std.c.malloc(@sizeOf(uv.uv_connect_t)) orelse @panic("malloc")));
    const socket: *uv.uv_tcp_t = @ptrCast(@alignCast(std.c.malloc(@sizeOf(uv.uv_tcp_t)) orelse @panic("malloc")));
    _ = uv.uv_tcp_init(loop, socket);

    _ = uv.uv_tcp_connect(connect_req, socket, res.*.ai_addr, on_connect);

    _ = uv.uv_freeaddrinfo(res);
}

pub fn main() void {
    loop = uv.uv_default_loop();

    const hints = uv.addrinfo{
        .ai_family = uv.PF_INET,
        .ai_socktype = uv.SOCK_STREAM,
        .ai_protocol = uv.IPPROTO_TCP,
        .ai_flags = 0,
    };

    var resolver = uv.uv_getaddrinfo_t{};
    std.debug.print("irc.libera.chat is... ", .{});
    const r = uv.uv_getaddrinfo(loop, &resolver, on_resolved, "irc.libera.chat", "6667", &hints);

    if (r != 0) {
        std.debug.print("getaddrinfo call error {s}\n", .{uv.uv_err_name(r)});
        std.c.exit(1);
        unreachable;
    }

    _ = uv.uv_run(loop, uv.UV_RUN_DEFAULT);
}
