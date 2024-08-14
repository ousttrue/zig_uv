const std = @import("std");

// 0: self
// 1: src
// 2: dst
pub fn main() !void {
    const dst = std.mem.span(std.os.argv[2]);
    std.debug.print("write to {s}\n", .{dst});
    const file = try std.fs.cwd().createFile(
        dst,
        .{},
    );
    defer file.close();
    const writer = file.writer();
    try writer.print("pub const X:i32=0;\n", .{});
}
