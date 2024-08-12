const std = @import("std");
const build_uv = @import("build_uv.zig");
const uvbook = @import("build_uvbook.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const libuv_dep = b.dependency("libuv", .{});
    const libuv = build_uv.build(b, target, optimize, libuv_dep);

    inline for (uvbook.samples) |sample| {
        const c_exe = b.addExecutable(.{
            .target = target,
            .optimize = optimize,
            .name = sample.name,
        });
        c_exe.addCSourceFile(.{
            .file = b.path(b.fmt("uvbook/{s}/main.c", .{sample.name})),
        });
        c_exe.linkLibrary(libuv.compile);
        c_exe.addIncludePath(libuv.include);
        // exe.root_module.addImport("uv", &libuv.compile.root_module);
        for (&libuv.windows_system_libs) |lib| {
            c_exe.linkSystemLibrary(lib);
        }
        b.installArtifact(c_exe);

        const run = b.addRunArtifact(c_exe);
        b.step("run-" ++ sample.name, "run main.zig").dependOn(&run.step);
    }
}
