const std = @import("std");
const build_uv = @import("build_uv.zig");

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libuv_dep = b.dependency("libuv", .{});

    const lib = b.addStaticLibrary(.{
        .target = target,
        .optimize = optimize,
        .name = "zig_uv",
        .root_source_file = b.path("c.zig"),
    });
    b.installArtifact(lib);
    lib.linkLibC();
    lib.addIncludePath(libuv_dep.path("include"));
    lib.addIncludePath(libuv_dep.path("src"));

    for (try build_uv.getSources(b, target)) |src| {
        lib.addCSourceFile(.{
            .file = libuv_dep.path(src),
            .flags = try build_uv.getFlags(b, target, optimize),
        });
    }
    for (try build_uv.getLibs(target, optimize)) |link| {
        lib.linkSystemLibrary(link);
    }

    _ = b.addModule("translated", .{
        .target = target,
        .optimize = optimize,
        .root_source_file = b.path("translated.zig"),
    });
}

// fn buildTranslated(
//     b: *std.Build,
//     target: std.Build.ResolvedTarget,
//     optimize: std.builtin.OptimizeMode,
//     root_source_file: std.Build.LazyPath,
// ) *std.Build.Step.Compile {
//     // > zig translate-c
//     // -I "zig\0.13.0\files\lib\include"
//     // -I "zig\0.13.0\files\lib\libc\include\any-windows-any"
//     // -I LOCALAPPDIR\zig\p\122023c580b23f2c7e08dbcab26190ac4b503f1516f702013821475817289088b585\include > translated.zig
//     // LOCALAPPDIR\zig\p\122023c580b23f2c7e08dbcab26190ac4b503f1516f702013821475817289088b585\include\uv.h
//     return lib;
// }
