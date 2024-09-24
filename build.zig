const std = @import("std");
const uvbook = @import("build_uvbook.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zig_uv_dep = b.dependency("zig_uv", .{
        .target = target,
        .optimize = optimize,
    });
    const zig_uv = zig_uv_dep.artifact("zig_uv");
    const translated_mod = zig_uv_dep.module("translated");

    const libuv_dep = zig_uv_dep.builder.dependency("libuv", .{});

    // generated: from libclang
    // const generated_zig = b.path("generated.zig");
    // const generate_step = generate(b, libuv_dep, generated_zig);
    // const generated = buildGenerated(
    //     b,
    //     target,
    //     optimize,
    //     generated_zig,
    // );
    // generated.step.dependOn(generate_step);

    for (uvbook.samples) |sample| {
        {
            const src = libuv_dep.path(b.fmt("docs/code/{s}/main.c", .{sample}));
            const exe = buildC(
                b,
                target,
                optimize,
                sample,
                libuv_dep.path("include"),
                zig_uv,
                src,
            );
            b.installArtifact(exe);
        }
        if (uvbook.get_zig(b, sample)) |src| {
            const exe = buildZig(
                b,
                target,
                optimize,
                translated_mod,
                zig_uv,
                sample,
                src,
            );
            b.installArtifact(exe);
        }
    }
}

fn generate(
    b: *std.Build,
    libuv_dep: *std.Build.Dependency,
    root_source_file: std.Build.LazyPath,
) *std.Build.Step {
    // make generator
    const tool = b.addExecutable(.{
        .target = b.host,
        .name = "generator",
        .root_source_file = b.path("generator/main.zig"),
    });
    tool.linkLibC();
    tool.addIncludePath(.{ .cwd_relative = "C:/Program Files/LLVM/include" });
    tool.addLibraryPath(.{ .cwd_relative = "C:/Program Files/LLVM/lib" });
    tool.linkSystemLibrary("libclang");
    // run: generator src.h dst.zig
    const tool_step = b.addRunArtifact(tool);
    tool_step.addPathDir("C:/Program Files/LLVM/bin");
    tool_step.addFileArg(libuv_dep.path("include/uv.h"));
    tool_step.addFileArg(root_source_file);
    // const output = tool_step.addOutputFileArg("generated.zig");
    // const output = tool_step.captureStdOut();
    // output
    return &tool_step.step;
}

fn buildGenerated(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    root_source_file: std.Build.LazyPath,
) *std.Build.Step.Compile {
    const lib = b.addStaticLibrary(.{
        .target = target,
        .optimize = optimize,
        .name = "generated",
        .root_source_file = root_source_file,
    });
    return lib;
}

fn buildC(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    name: []const u8,
    libuv_include: std.Build.LazyPath,
    libuv_compile: *std.Build.Step.Compile,
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
    exe.addIncludePath(libuv_include);
    exe.linkLibrary(libuv_compile);
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
    translated: *std.Build.Module,
    libuv_compile: *std.Build.Step.Compile,
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
    exe.root_module.addImport("uv", &libuv_compile.root_module);
    exe.root_module.addImport("translated", translated);
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
