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

| name                                                                           | c-win32 | zig |     |
| ------------------------------------------------------------------------------ | ------- | --- | --- |
| [uvcat](https://github.com/libuv/libuv/blob/v1.x/docs/code/uvcat/main.c)       | o       | o   |     |
| [uvtee](https://github.com/libuv/libuv/blob/v1.x/docs/code/uvtee/main.c)       | o       |     |     |
| [onchange](https://github.com/libuv/libuv/blob/v1.x/docs/code/onchange/main.c) | o       |     |     |

### [Networking](https://docs.libuv.org/en/v1.x/guide/networking.html)

| name            | c-win32 | zig |     |
| --------------- | ------- | --- | --- |
| tcp-echo-server | o       |     |     |
| udp-dhcp        | o       |     |     |
| dns             | o       |     |     |
| interfaces      | o       |     |     |

### [Threads](https://docs.libuv.org/en/v1.x/guide/threads.html)

| name          | c-win32         | zig |     |
| ------------- | --------------- | --- | --- |
| thread-create | c               |     |     |
| locks         | uv_barrier_wait |     |     |
| queue-work    | `<unistd.h>`    |     |     |
| queue-cancel  | `<unistd.h>`    |     |     |
| progress      | `<unistd.h>`    |     |     |

### [Process](https://docs.libuv.org/en/v1.x/guide/process.html)

| name              | c-win32      | zig |              |
| ----------------- | ------------ | --- | ------------ |
| spawn             | o            |     |              |
| detach            | o            |     |              |
| signal            | `<unistd.h>` |     |              |
| proc-streams      | o            |     |              |
| cgi               | o            |     | and cgi/tick |
| pipe-echo-server  | o            |     |              |
| multi-echo-server | o            |     |              |

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
