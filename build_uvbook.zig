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
    "uvcat",
    "uvtee",
    "onchange",
    "tcp-echo-server",
    "udp-dhcp",
    "dns",
    "interfaces",
    "thread-create",
    // "locks", uv_barrier_wait
    // "queue-work",
    // "queue-cancel",
    // "progress",
    "spawn",
    "detach",
    // "signal",
    "proc-streams",
    "cgi", // and cgi/tick.
    "pipe-echo-server",
    "multi-echo-server",
    "uvstop",
    "ref-timer",
    "idle-compute",
    // "uvwget",
    "plugin", // and plugin/hello.c
    "tty",
    "tty-gravity",
};
