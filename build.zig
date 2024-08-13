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
            const src = libuv_dep.path(b.fmt("docs/code/{s}/main.c", .{sample}));
            const exe = buildC(
                b,
                target,
                optimize,
                &libuv,
                sample,
                src,
            );
            b.installArtifact(exe);
        }
        if (uvbook.get_zig(b, sample)) |src| {
            const exe = buildZig(
                b,
                target,
                optimize,
                &libuv,
                sample,
                src,
            );
            b.installArtifact(exe);
        }
    }
}

fn buildC(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    libuv: *const build_uv.Lib,
    name: []const u8,
    src: std.Build.LazyPath,
) *std.Build.Step.Compile {
    const exe = b.addExecutable(.{
        .target = target,
        .optimize = optimize,
        .name = b.fmt("c_{s}", .{name}),
    });
    // entry point
    exe.addCSourceFile(.{
        .file = src,
    });
    exe.addIncludePath(libuv.include);
    exe.linkLibrary(libuv.compile);
    // link for libuv
    for (&libuv.windows_system_libs) |lib| {
        exe.linkSystemLibrary(lib);
    }
    // run
    const run = b.addRunArtifact(exe);
    b.step(
        b.fmt("c_{s}", .{name}),
        b.fmt("Build & run c_{s}", .{name}),
    ).dependOn(&run.step);
    return exe;
}

fn buildZig(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    libuv: *const build_uv.Lib,
    name: []const u8,
    src: []const u8,
) *std.Build.Step.Compile {
    // zig
    const exe = b.addExecutable(.{
        .target = target,
        .optimize = optimize,
        .name = b.fmt("zig_{s}", .{name}),
        // entry point
        .root_source_file = b.path(src),
    });
    exe.root_module.addImport("uv", &libuv.compile.root_module);
    // link for libuv
    for (&libuv.windows_system_libs) |lib| {
        exe.linkSystemLibrary(lib);
    }
    // run
    const run = b.addRunArtifact(exe);
    b.step(
        b.fmt("zig_{s}", .{name}),
        b.fmt("Build & run zig_{s}", .{name}),
    ).dependOn(&run.step);
    return exe;
}
