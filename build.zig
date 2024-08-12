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
                .name = sample.name,
            });
            exe.addCSourceFile(.{
                .file = b.path(b.fmt("uvbook/{s}/main.c", .{sample.name})),
            });
            exe.linkLibrary(libuv.compile);
            exe.addIncludePath(libuv.include);
            for (&libuv.windows_system_libs) |lib| {
                exe.linkSystemLibrary(lib);
            }
            b.installArtifact(exe);

            const run = b.addRunArtifact(exe);
            b.step(
                b.fmt("c-{s}", .{sample.name}),
                b.fmt("run {s}", .{sample.name}),
            ).dependOn(&run.step);
        }
        {
            // zig
            const exe = b.addExecutable(.{
                .target = target,
                .optimize = optimize,
                .name = sample.name,
                .root_source_file = b.path(b.fmt("uvbook/{s}/main.zig", .{sample.name})),
            });
            exe.root_module.addImport("uv", &libuv.compile.root_module);
            for (&libuv.windows_system_libs) |lib| {
                exe.linkSystemLibrary(lib);
            }
            b.installArtifact(exe);

            const run = b.addRunArtifact(exe);
            b.step(
                b.fmt("zig-{s}", .{sample.name}),
                b.fmt("run {s}", .{sample.name}),
            ).dependOn(&run.step);
        }
    }
}
