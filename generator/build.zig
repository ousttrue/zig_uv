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


