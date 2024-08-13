const std = @import("std");

pub const Sample = struct {
    name: []const u8,

    pub fn get_zig(self: @This(), b: *std.Build) ?[]const u8 {
        const path = b.fmt("uvbook/{s}/main.zig", .{self.name});
        std.fs.accessAbsolute(b.path(path).getPath(b), .{}) catch {
            return null;
        };
        return path;
    }
};

pub const samples = [_]Sample{
    .{
        .name = "helloworld",
    },
    .{
        .name = "idle-basic",
    },
};
