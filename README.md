# libuv from zig

`zig-0.13.0`

## dependencies

```sh
zig fetch --save=libuv git+https://github.com/libuv/libuv.git#v1.48.0
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
| [idle-basic](https://github.com/libuv/libuv/blob/v1.x/docs/code/idle-basic/main.c) | o       |     |     |

### [Filesystem](https://docs.libuv.org/en/v1.x/guide/filesystem.html)

| name                                                                           | c-win32 | zig |     |
| ------------------------------------------------------------------------------ | ------- | --- | --- |
| [uvcat](https://github.com/libuv/libuv/blob/v1.x/docs/code/uvcat/main.c)       | o       |     |     |
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
