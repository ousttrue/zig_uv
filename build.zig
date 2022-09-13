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

const LIBUV_DEFINITIONS_WINDOWS = [_][]const u8{
    "-DWIN32_LEAN_AND_MEAN",
    "-D_WIN32_WINNT=0x0602",
};

const LIBUV_LIBS_WINDOWS = [_][]const u8{
    "psapi",
    "user32",
    "advapi32",
    "iphlpapi",
    "userenv",
    "ws2_32",
};

const LIBUV_SOURCES_UNIX = [_][]const u8{
    "libuv/src/unix/async.c",
    "libuv/src/unix/core.c",
    "libuv/src/unix/dl.c",
    "libuv/src/unix/fs.c",
    "libuv/src/unix/getaddrinfo.c",
    "libuv/src/unix/getnameinfo.c",
    "libuv/src/unix/loop-watcher.c",
    "libuv/src/unix/loop.c",
    "libuv/src/unix/pipe.c",
    "libuv/src/unix/poll.c",
    "libuv/src/unix/process.c",
    "libuv/src/unix/random-devurandom.c",
    "libuv/src/unix/signal.c",
    "libuv/src/unix/stream.c",
    "libuv/src/unix/tcp.c",
    "libuv/src/unix/thread.c",
    "libuv/src/unix/tty.c",
    "libuv/src/unix/udp.c",
    "libuv/src/unix/proctitle.c",
};

const LIBUV_DEFINITIONS_UNIX = [_][]const u8{
    // "-D_FILE_OFFSET_BITS=64",
    "-D_LARGEFILE_SOURCE",
};

const LIBUV_DEFINITIONS_LINUX = [_][]const u8{
    "-D_GNU_SOURCE", "-D_POSIX_C_SOURCE=200112",
};

const LIBUV_LIBS_LINUX = [_][]const u8{
    "dl", "rt",
};

const LIBUV_SOURCES_LINUX = [_][]const u8{
    "libuv/src/unix/linux-core.c",
    "libuv/src/unix/linux-inotify.c",
    "libuv/src/unix/linux-syscalls.c",
    "libuv/src/unix/procfs-exepath.c",
    "libuv/src/unix/random-getrandom.c",
    "libuv/src/unix/random-sysctl-linux.c",
    "libuv/src/unix/epoll.c",
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
    if (target.isWindows()) {
        exe.addCSourceFiles(&(LIBUV_SOURCES ++ LIBUV_SOURCES_WINDOWS), &LIBUV_DEFINITIONS_WINDOWS);
        for (&LIBUV_LIBS_WINDOWS) |lib| {
            exe.linkSystemLibrary(lib);
        }
    } else {
        exe.addCSourceFiles(
            &(LIBUV_SOURCES ++ LIBUV_SOURCES_UNIX ++ LIBUV_SOURCES_LINUX),
            &(LIBUV_DEFINITIONS_UNIX ++ LIBUV_DEFINITIONS_LINUX),
        );
        for (&LIBUV_LIBS_LINUX) |lib| {
            exe.linkSystemLibrary(lib);
        }
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
