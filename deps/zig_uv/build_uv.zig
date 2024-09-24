const std = @import("std");

pub const LIBUV_SOURCES = [_][]const u8{
    "src/fs-poll.c",
    "src/idna.c",
    "src/inet.c",
    "src/random.c",
    "src/strscpy.c",
    "src/strtok.c",
    "src/threadpool.c",
    "src/timer.c",
    "src/uv-common.c",
    "src/uv-data-getter-setters.c",
    "src/version.c",
};

pub const LIBUV_SOURCES_WINDOWS = [_][]const u8{
    "src/win/async.c",
    "src/win/core.c",
    "src/win/detect-wakeup.c",
    "src/win/dl.c",
    "src/win/error.c",
    "src/win/fs.c",
    "src/win/fs-event.c",
    "src/win/getaddrinfo.c",
    "src/win/getnameinfo.c",
    "src/win/handle.c",
    "src/win/loop-watcher.c",
    "src/win/pipe.c",
    "src/win/thread.c",
    "src/win/poll.c",
    "src/win/process.c",
    "src/win/process-stdio.c",
    "src/win/signal.c",
    "src/win/snprintf.c",
    "src/win/stream.c",
    "src/win/tcp.c",
    "src/win/tty.c",
    "src/win/udp.c",
    "src/win/util.c",
    "src/win/winapi.c",
    "src/win/winsock.c",
};

pub const LIBUV_DEFINITIONS_WINDOWS = [_][]const u8{
    "-D_WIN32",
    "-DWIN32_LEAN_AND_MEAN",
    // "-fno-strict-aliasing",
    "-D_WIN32_WINNT=0x0600",
    // "-D_WIN32_WINNT=0x0602",
};

pub const LIBUV_LIBS_WINDOWS = [_][]const u8{
    "psapi",
    "user32",
    "advapi32",
    "iphlpapi",
    "userenv",
    "ws2_32",
    "ole32",
    //
    "Dbghelp",
    // "asan",
};

pub const LIBUV_SOURCES_UNIX = [_][]const u8{
    "src/unix/async.c",
    "src/unix/core.c",
    "src/unix/dl.c",
    "src/unix/fs.c",
    "src/unix/getaddrinfo.c",
    "src/unix/getnameinfo.c",
    "src/unix/loop-watcher.c",
    "src/unix/loop.c",
    "src/unix/pipe.c",
    "src/unix/poll.c",
    "src/unix/process.c",
    "src/unix/random-devurandom.c",
    "src/unix/signal.c",
    "src/unix/stream.c",
    "src/unix/tcp.c",
    "src/unix/thread.c",
    "src/unix/tty.c",
    "src/unix/udp.c",
    "src/unix/proctitle.c",
};

pub const LIBUV_DEFINITIONS_UNIX = [_][]const u8{
    // "-D_FILE_OFFSET_BITS=64",
    "-D_LARGEFILE_SOURCE",
};

pub const LIBUV_DEFINITIONS_LINUX = [_][]const u8{
    "-D_GNU_SOURCE", "-D_POSIX_C_SOURCE=200112",
};

pub const LIBUV_LIBS_LINUX = [_][]const u8{
    "dl", "rt",
};

pub const LIBUV_SOURCES_LINUX = [_][]const u8{
    "src/unix/linux-core.c",
    "src/unix/linux-inotify.c",
    "src/unix/linux-syscalls.c",
    "src/unix/procfs-exepath.c",
    "src/unix/random-getrandom.c",
    "src/unix/random-sysctl-linux.c",
    "src/unix/epoll.c",
};

pub const DEBUG_FLAGS = [_][]const u8{
    "-g",
    // "-Ilibuv/include",
    // "-Ilibuv/src",
    "-fno-rtti",
    // "-fsanitize=undefined,address",
    "-fno-omit-frame-pointer",
};
