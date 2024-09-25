const std = @import("std");
const uvbook = @import("uvbook");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const zig_uv_dep = b.dependency("zig_uv", .{
        .target = target,
        .optimize = optimize,
    });
    const zig_uv = zig_uv_dep.artifact("zig_uv");
    b.installArtifact(zig_uv);

    if (b.option(bool, "uvbook", "build uvbook samples") orelse false) {
        const uvbook_dep = b.dependency("uvbook", .{});
        const translated_mod = zig_uv_dep.module("translated");
        const libuv_dep = zig_uv_dep.builder.dependency("libuv", .{});
        for (uvbook.samples) |sample| {
            {
                const exe = buildC(
                    b,
                    target,
                    optimize,
                    sample,
                    libuv_dep,
                    zig_uv,
                );
                const install = b.addInstallArtifact(exe, .{});
                b.getInstallStep().dependOn(&install.step);

                const run = b.addRunArtifact(exe);
                run.step.dependOn(&install.step);

                b.step(
                    b.fmt("c-{s}", .{sample}),
                    b.fmt("Run {s} (c)", .{sample}),
                ).dependOn(&run.step);
            }
            if (uvbook.get_zig(uvbook_dep, sample)) |src| {
                const exe = uvbook.buildZig(
                    uvbook_dep,
                    b,
                    target,
                    optimize,
                    translated_mod,
                    zig_uv,
                    sample,
                    src,
                );
                const install = b.addInstallArtifact(exe, .{});
                b.getInstallStep().dependOn(&install.step);

                const run = b.addRunArtifact(exe);
                run.step.dependOn(&install.step);

                b.step(
                    b.fmt("zig-{s}", .{sample}),
                    b.fmt("Run {s} (zig)", .{sample}),
                ).dependOn(&run.step);
            }
        }
    }
}

pub fn buildC(
    b: *std.Build,
    target: std.Build.ResolvedTarget,
    optimize: std.builtin.OptimizeMode,
    name: []const u8,
    libuv_dep: *std.Build.Dependency,
    libuv_compile: *std.Build.Step.Compile,
) *std.Build.Step.Compile {
    const exe = b.addExecutable(.{
        .target = target,
        .optimize = optimize,
        .name = b.fmt("c_{s}", .{name}),
    });
    // entry point
    exe.addCSourceFiles(.{
        .root = libuv_dep.path(""),
        .files = &.{b.fmt("docs/code/{s}/main.c", .{name})},
    });
    exe.addIncludePath(libuv_dep.path("include"));
    exe.linkLibrary(libuv_compile);
    return exe;
}
