const std = @import("std");

pub fn build(b: *std.Build) void {
    _ = b;
}

pub fn get_zig(dep: *std.Build.Dependency, name: []const u8) ?[]const u8 {
    const b = dep.builder;
    const path = b.fmt("{s}/main.zig", .{name});
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

pub fn buildZig(
    uvbook_dep: *std.Build.Dependency,
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    translated: *std.Build.Module,
    libuv_compile: *std.Build.Step.Compile,
    name: []const u8,
    src: []const u8,
) *std.Build.Step.Compile {
    const exe = b.addExecutable(.{
        .target = target,
        .optimize = optimize,
        .name = b.fmt("zig_{s}", .{name}),
        // entry point
        .root_source_file = uvbook_dep.path(src),
    });
    exe.root_module.addImport("uv", &libuv_compile.root_module);
    exe.root_module.addImport("translated", translated);
    return exe;
}
