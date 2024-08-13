const std = @import("std");

pub fn get_zig(b: *std.Build, name: []const u8) ?[]const u8 {
    const path = b.fmt("uvbook/{s}/main.zig", .{name});
    std.fs.accessAbsolute(b.path(path).getPath(b), .{}) catch {
        return null;
    };
    return path;
}

pub const samples = [_][]const u8{
    "helloworld",
    "idle-basic",
};
