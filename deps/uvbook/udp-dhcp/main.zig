const std = @import("std");
const uv = @import("uv");

var loop: *uv.uv_loop_t = undefined;
var send_socket = uv.uv_udp_t{};
var recv_socket = uv.uv_udp_t{};

export fn alloc_buffer(_: [*c]uv.uv_handle_t, suggested_size: usize, buf: [*c]uv.uv_buf_t) void {
    buf.*.base = @ptrCast(std.c.malloc(suggested_size) orelse @panic("malloc"));
    buf.*.len = @intCast(suggested_size);
}

export fn on_read(req: [*c]uv.uv_udp_t, nread: isize, buf: [*c]const uv.uv_buf_t, addr: [*c]const uv.sockaddr, _: c_uint) void {
    if (nread < 0) {
        std.debug.print("Read error {s}\n", .{uv.uv_err_name(@intCast(nread))});
        _ = uv.uv_close(@ptrCast(req), null);
        std.c.free(buf.*.base);
        return;
    }

    var sender = std.mem.zeroes([17]c_char);
    _ = uv.uv_ip4_name(@ptrCast(@alignCast(addr)), @ptrCast(&sender[0]), 16);
    std.debug.print("Recv from {any}\n", .{sender});

    // ... DHCP specific code
    const as_integer: [*]u32 = @ptrCast(@alignCast(buf.*.base));
    const ipbin = uv.ntohl(as_integer[4]);
    var ip = [4]u8{ 0, 0, 0, 0 };
    for (0..4) |i| {
        ip[i] = @intCast((ipbin >> @as(u5, @intCast(i)) * 8) & 0xff);
    }
    std.debug.print("Offered IP {}.{}.{}.{}\n", .{ ip[3], ip[2], ip[1], ip[0] });

    std.c.free(buf.*.base);
    _ = uv.uv_udp_recv_stop(req);
}

fn make_discover_msg() uv.uv_buf_t {
    var buffer = uv.uv_buf_t{};
    alloc_buffer(null, 256, &buffer);
    @memset(buffer.base[0..buffer.len], 0);

    // BOOTREQUEST
    buffer.base[0] = 0x1;
    // HTYPE ethernet
    buffer.base[1] = 0x1;
    // HLEN
    buffer.base[2] = 0x6;
    // HOPS
    buffer.base[3] = 0x0;
    // XID 4 bytes
    if (uv.uv_random(null, null, &buffer.base[4], 4, 0, null) != 0)
        @panic("uv_random");
    // SECS
    buffer.base[8] = 0x0;
    // FLAGS
    buffer.base[10] = 0x80;
    // CIADDR 12-15 is all zeros
    // YIADDR 16-19 is all zeros
    // SIADDR 20-23 is all zeros
    // GIADDR 24-27 is all zeros
    // CHADDR 28-43 is the MAC address, use your own
    buffer.base[28] = 0xe4;
    buffer.base[29] = 0xce;
    buffer.base[30] = 0x8f;
    buffer.base[31] = 0x13;
    buffer.base[32] = 0xf6;
    buffer.base[33] = 0xd4;
    // SNAME 64 bytes zero
    // FILE 128 bytes zero
    // OPTIONS
    // - magic cookie
    buffer.base[236] = 99;
    buffer.base[237] = 130;
    buffer.base[238] = 83;
    buffer.base[239] = 99;

    // DHCP Message type
    buffer.base[240] = 53;
    buffer.base[241] = 1;
    buffer.base[242] = 1; // DHCPDISCOVER

    // DHCP Parameter request list
    buffer.base[243] = 55;
    buffer.base[244] = 4;
    buffer.base[245] = 1;
    buffer.base[246] = 3;
    buffer.base[247] = 15;
    buffer.base[248] = 6;

    return buffer;
}

export fn on_send(_: [*c]uv.uv_udp_send_t, status: c_int) void {
    if (status != 0) {
        std.debug.print("Send error {s}\n", .{uv.uv_strerror(status)});
        return;
    }
}

pub fn main() void {
    loop = uv.uv_default_loop();

    _ = uv.uv_udp_init(loop, &recv_socket);
    var recv_addr = uv.sockaddr_in{};
    _ = uv.uv_ip4_addr("0.0.0.0", 68, &recv_addr);
    _ = uv.uv_udp_bind(&recv_socket, @ptrCast(&recv_addr), uv.UV_UDP_REUSEADDR);
    _ = uv.uv_udp_recv_start(&recv_socket, alloc_buffer, on_read);

    _ = uv.uv_udp_init(loop, &send_socket);
    var broadcast_addr = uv.sockaddr_in{};
    _ = uv.uv_ip4_addr("0.0.0.0", 0, &broadcast_addr);
    _ = uv.uv_udp_bind(&send_socket, @ptrCast(&broadcast_addr), 0);
    _ = uv.uv_udp_set_broadcast(&send_socket, 1);

    var send_req = uv.uv_udp_send_t{};
    const discover_msg = make_discover_msg();

    var send_addr = uv.sockaddr_in{};
    _ = uv.uv_ip4_addr("255.255.255.255", 67, &send_addr);
    _ = uv.uv_udp_send(&send_req, &send_socket, &discover_msg, 1, @ptrCast(&send_addr), on_send);

    _ = uv.uv_run(loop, uv.UV_RUN_DEFAULT);
}
