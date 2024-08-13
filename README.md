# libuv from zig

`zig-0.13.0`

## dependencies

`master required` `v1.48.0` has CONTAINING_RECORD issue.

```sh
> zig fetch --save=libuv git+https://github.com/libuv/libuv.git
```

## trobule

### CONTAINING_RECORD cause runtime INVALID INSTRUCTION

patch for src/win/req-inl.h

```c
INLINE static uv_req_t* uv__overlapped_to_req(OVERLAPPED* overlapped) {
  // cause illegal instruction
  // return CONTAINING_RECORD(overlapped, uv_req_t, u.io.overlapped);
  return (uv_req_t*)((char*)overlapped - offsetof(uv_req_t, u.io.overlapped));
}
```

same https://github.com/libuv/libuv/pull/4254

merged 2024/08/06

### uv_pipe_t has dependency loop

- https://github.com/ziglang/zig/issues/18247

```zig
pub const struct_uv_stream_s = extern struct {
    read_cb: uv_read_cb = @import("std").mem.zeroes(uv_read_cb),
};

// 👆👇

pub const uv_read_cb = ?*const fn ([*c]uv_stream_t, isize, [*c]const uv_buf_t) callconv(.C) void;

// workaround

pub const uv_read_cb = ?*const fn (*anyopaque, isize, [*c]const uv_buf_t) callconv(.C) void;
```

## uvbook

- https://docs.libuv.org/en/v1.x/guide/introduction.html

```sh
> zig build -l
  install (default)            Copy build artifacts to prefix path
  uninstall                    Remove build artifacts from prefix path
  c_helloworld                 Build & run c_helloworld
  zig_helloworld               Build & run zig_helloworld

> zig build c-helloworld
```

### [Basics of libuv]https://docs.libuv.org/en/v1.x/guide/basics.html

| name                                                                               | c-win32 | zig |     |
| ---------------------------------------------------------------------------------- | ------- | --- | --- |
| [helloworld](https://github.com/libuv/libuv/blob/v1.x/docs/code/helloworld/main.c) | o       | o   |     |
| [idle-basic](https://github.com/libuv/libuv/blob/v1.x/docs/code/idle-basic/main.c) | o       | o   |     |

### [Filesystem](https://docs.libuv.org/en/v1.x/guide/filesystem.html)

| name                                                                           | c-win32 | zig |                   |
| ------------------------------------------------------------------------------ | ------- | --- | ----------------- |
| [uvcat](https://github.com/libuv/libuv/blob/v1.x/docs/code/uvcat/main.c)       | o       | o   |                   |
| [uvtee](https://github.com/libuv/libuv/blob/v1.x/docs/code/uvtee/main.c)       | o       | o   | `dependency loop` |
| [onchange](https://github.com/libuv/libuv/blob/v1.x/docs/code/onchange/main.c) | o       | o   |                   |

### [Networking](https://docs.libuv.org/en/v1.x/guide/networking.html)

| name                                                                                         | c-win32 | zig |                |
| -------------------------------------------------------------------------------------------- | ------- | --- | -------------- |
| [tcp-echo-server](https://github.com/libuv/libuv/blob/v1.x/docs/code/tcp-echo-server/main.c) | o       | o   | TODO: client   |
| [udp-dhcp](https://github.com/libuv/libuv/blob/v1.x/docs/code/udp-dhcp/main.c)               | o       | o   |                |
| [dns](https://github.com/libuv/libuv/blob/v1.x/docs/code/dns/main.c)                         | o       | x   | TODO: not work |
| [interfaces](https://github.com/libuv/libuv/blob/v1.x/docs/code/interfaces/main.c)           | o       | x   | @cimport error |

### [Threads](https://docs.libuv.org/en/v1.x/guide/threads.html)

| name                                                                                     | c-win32         | zig |     |
| ---------------------------------------------------------------------------------------- | --------------- | --- | --- |
| [thread-create](https://github.com/libuv/libuv/blob/v1.x/docs/code/thread-create/main.c) | c               | o   |     |
| [locks](https://github.com/libuv/libuv/blob/v1.x/docs/code/locks/main.c)                 | uv_barrier_wait |     |     |
| [queue-work](https://github.com/libuv/libuv/blob/v1.x/docs/code/queue-work/main.c)       | `<unistd.h>`    |     |     |
| [queue-cancel](https://github.com/libuv/libuv/blob/v1.x/docs/code/queue-cancel/main.c)   | `<unistd.h>`    |     |     |
| [progress](https://github.com/libuv/libuv/blob/v1.x/docs/code/progress/main.c)           | `<unistd.h>`    |     |     |

### [Process](https://docs.libuv.org/en/v1.x/guide/process.html)

| name                                                                                             | c-win32      | zig |              |
| ------------------------------------------------------------------------------------------------ | ------------ | --- | ------------ |
| [spawn](https://github.com/libuv/libuv/blob/v1.x/docs/code/spawn/main.c)                         | o            | o   |              |
| [detach](https://github.com/libuv/libuv/blob/v1.x/docs/code/detach/main.c)                       | o            |     |              |
| [signal](https://github.com/libuv/libuv/blob/v1.x/docs/code/signal/main.c)                       | `<unistd.h>` |     |              |
| [proc-streams](https://github.com/libuv/libuv/blob/v1.x/docs/proc-streams/locks/main.c)          | o            |     |              |
| [cgi](https://github.com/libuv/libuv/blob/v1.x/docs/code/cgi/main.c)                             | o            |     | and cgi/tick |
| [pipe-echo-server](https://github.com/libuv/libuv/blob/v1.x/docs/code/pipe-echo-server/main.c)   | o            |     |              |
| [multi-echo-server](https://github.com/libuv/libuv/blob/v1.x/docs/code/multi-echo-server/main.c) | o            |     |              |

### [Advanced event loops](https://docs.libuv.org/en/v1.x/guide/eventloops.html)

| name   | c-win32 | zig |     |
| ------ | ------- | --- | --- |
| uvstop | o       |     |     |

### [Utilities](https://docs.libuv.org/en/v1.x/guide/utilities.html)

| name         | c-win32    | zig |                    |
| ------------ | ---------- | --- | ------------------ |
| ref-timer    | o          |     |                    |
| idle-compute | o          |     |                    |
| uvwget       | `<curl.h>` |     |                    |
| plugin       | o          |     | and plugin/hello.c |
| tty          | o          |     |                    |
| tty-gravity  | o          |     |                    |
