const std = @import("std");
const build_uv = @import("build_uv.zig");
const uvbook = @import("build_uvbook.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libuv_dep = b.dependency("libuv", .{});
    const libuv = build_uv.build(b, target, optimize, libuv_dep);

    const translated = buildTranslated(b, target, optimize);

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
            exe.root_module.addImport("translated", &translated.root_module);
            b.installArtifact(exe);
        }
    }
}

fn buildTranslated(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
) *std.Build.Step.Compile {
    // > zig translate-c
    // -I "zig\0.13.0\files\lib\include"
    // -I "zig\0.13.0\files\lib\libc\include\any-windows-any"
    // -I LOCALAPPDIR\zig\p\122023c580b23f2c7e08dbcab26190ac4b503f1516f702013821475817289088b585\include > translated.zig
    // LOCALAPPDIR\zig\p\122023c580b23f2c7e08dbcab26190ac4b503f1516f702013821475817289088b585\include\uv.h
    const lib = b.addStaticLibrary(.{
        .target = target,
        .optimize = optimize,
        .name = "translated",
        .root_source_file = b.path("translated.zig"),
    });
    return lib;
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
    if (b.args) |args| {
        run.addArgs(args);
    }
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
    if (b.args) |args| {
        run.addArgs(args);
    }
    b.step(
        b.fmt("zig_{s}", .{name}),
        b.fmt("Build & run zig_{s}", .{name}),
    ).dependOn(&run.step);
    return exe;
}
