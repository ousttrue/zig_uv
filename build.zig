const std = @import("std");

const c_pkg = std.build.Pkg{
    .name = "c",
    .source = .{ .path = "c.zig" },
};

const LIBUV_SOURCES = [_][]const u8{
    "libuv/src/fs-poll.c",
    "libuv/src/idna.c",
    "libuv/src/inet.c",
    "libuv/src/random.c",
    "libuv/src/strscpy.c",
    "libuv/src/strtok.c",
    "libuv/src/threadpool.c",
    "libuv/src/timer.c",
    "libuv/src/uv-common.c",
    "libuv/src/uv-data-getter-setters.c",
    "libuv/src/version.c",
};

const LIBUV_SOURCES_WINDOWS = [_][]const u8{
    "libuv/src/win/async.c",
    "libuv/src/win/core.c",
    "libuv/src/win/detect-wakeup.c",
    "libuv/src/win/dl.c",
    "libuv/src/win/error.c",
    "libuv/src/win/fs.c",
    "libuv/src/win/fs-event.c",
    "libuv/src/win/getaddrinfo.c",
    "libuv/src/win/getnameinfo.c",
    "libuv/src/win/handle.c",
    "libuv/src/win/loop-watcher.c",
    "libuv/src/win/pipe.c",
    "libuv/src/win/thread.c",
    "libuv/src/win/poll.c",
    "libuv/src/win/process.c",
    "libuv/src/win/process-stdio.c",
    "libuv/src/win/signal.c",
    "libuv/src/win/snprintf.c",
    "libuv/src/win/stream.c",
    "libuv/src/win/tcp.c",
    "libuv/src/win/tty.c",
    "libuv/src/win/udp.c",
    "libuv/src/win/util.c",
    "libuv/src/win/winapi.c",
    "libuv/src/win/winsock.c",
};

pub fn build(b: *std.build.Builder) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target = b.standardTargetOptions(.{});

    // Standard release options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall.
    const mode = b.standardReleaseOptions();

    const exe = b.addExecutable("zig_uv", "src/main.zig");
    exe.setTarget(target);
    exe.setBuildMode(mode);

    exe.use_stage1 = true;
    exe.linkLibC();
    exe.linkLibCpp();
    exe.addIncludePath("libuv/include");
    // exe.addIncludePath("libuv/include/uv");
    exe.addIncludePath("libuv/src");
    exe.addPackage(c_pkg);
    exe.addCSourceFiles(&(LIBUV_SOURCES ++ LIBUV_SOURCES_WINDOWS), &.{
        "-DWIN32_LEAN_AND_MEAN",
        "-D_WIN32_WINNT=0x0602",
    });
    for (&[_][]const u8{
        "psapi",
        "user32",
        "advapi32",
        "iphlpapi",
        "userenv",
        "ws2_32",
    }) |lib| {
        exe.linkSystemLibrary(lib);
    }

    exe.install();

    const run_cmd = exe.run();
    run_cmd.step.dependOn(b.getInstallStep());
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_tests = b.addTest("src/main.zig");
    exe_tests.setTarget(target);
    exe_tests.setBuildMode(mode);

    const test_step = b.step("test", "Run unit tests");
    test_step.dependOn(&exe_tests.step);
}
