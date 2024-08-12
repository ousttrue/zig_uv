const std = @import("std");
const build_uv = @import("build_uv.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libuv_dep = b.dependency("libuv", .{});
    const libuv = build_uv.build(b, target, optimize, libuv_dep);

    const exe = b.addExecutable(.{
        .target = target,
        .optimize = optimize,
        .name = "sample",
        .root_source_file = b.path("src/main.zig"),
    });
    exe.root_module.addImport("uv", &libuv.compile.root_module);
    exe.linkLibC();
    b.installArtifact(exe);

    for (&libuv.windows_system_libs) |lib| {
        exe.linkSystemLibrary(lib);
    }

    const run = b.addRunArtifact(exe);
    b.step("run", "run main.zig").dependOn(&run.step);
}
