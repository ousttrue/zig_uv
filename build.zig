const std = @import("std");
const build_uv = @import("build_uv.zig");
const uvbook = @import("build_uvbook.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libuv_dep = b.dependency("libuv", .{});
    const libuv = build_uv.build(b, target, optimize, libuv_dep);

    for (uvbook.samples) |sample| {
        {
            // c
            const exe = b.addExecutable(.{
                .target = target,
                .optimize = optimize,
                .name = sample,
            });
            // entry point
            const c_main = libuv_dep.path(b.fmt("docs/code/{s}/main.c", .{sample}));
            exe.addCSourceFile(.{
                .file = c_main,
            });
            exe.addIncludePath(libuv.include);
            exe.linkLibrary(libuv.compile);
            // link for libuv
            for (&libuv.windows_system_libs) |lib| {
                exe.linkSystemLibrary(lib);
            }
            b.installArtifact(exe);
            // run
            const run = b.addRunArtifact(exe);
            b.step(
                b.fmt("c-{s}", .{sample}),
                b.fmt("run {s}", .{sample}),
            ).dependOn(&run.step);
        }
        if (uvbook.get_zig(b, sample)) |src| {
            // zig
            const exe = b.addExecutable(.{
                .target = target,
                .optimize = optimize,
                .name = sample,
                // entry point
                .root_source_file = b.path(src),
            });
            exe.root_module.addImport("uv", &libuv.compile.root_module);
            // link for libuv
            for (&libuv.windows_system_libs) |lib| {
                exe.linkSystemLibrary(lib);
            }
            b.installArtifact(exe);
            // run
            const run = b.addRunArtifact(exe);
            b.step(
                b.fmt("zig-{s}", .{sample}),
                b.fmt("run {s}", .{sample}),
            ).dependOn(&run.step);
        }
    }
}
