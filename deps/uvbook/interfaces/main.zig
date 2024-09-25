const std = @import("std");
const uv = @import("uv");

pub fn main() void {
    @panic("@cimport: error");

    // var buf: [512]u8 = undefined;
    // var info: *anyopaque= undefined;
    // var count: c_int = undefined;
    // opaque types have unknown size and therefore cannot be directly embedded in unions
    // _ = uv.uv_interface_addresses(&info, &count);
    // var i = count - 1;
    // std.debug.print("Number of interfaces: {}\n", .{count});
    // while (i >= 0) : (i -= 1) {
    //     const interface_a = info[i];
    //
    //     std.debug.print("Name: {s}\n", .{interface_a.name});
    //     std.debug.print("Internal? {s}\n", .{if (interface_a.is_internal) "Yes" else "No"});
    //
    //     if (interface_a.address.address4.sin_family == uv.AF_INET) {
    //         _ = uv.uv_ip4_name(&interface_a.address.address4, &buf[0], @sizeOf(@TypeOf(buf)));
    //         std.debug.print("IPv4 address: {s}\n", .{buf});
    //     } else if (interface_a.address.address4.sin_family == uv.AF_INET6) {
    //         _ = uv.uv_ip6_name(&interface_a.address.address6, buf, @sizeOf(@TypeOf(buf)));
    //         std.debug.print("IPv6 address: {s}\n", buf);
    //     }
    //
    //     std.debug.print("\n", .{});
    // }

    // _ = uv.uv_free_interface_addresses(info, count);
}
