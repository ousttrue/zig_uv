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
  c-helloworld                 run helloworld
  zig-helloworld               run c-helloworld

> zig build c-helloworld
```

| name              | c(widdows)      | zig |                    |
| ----------------- | --------------- | --- | ------------------ |
| helloworld        | o               | o   |
| idle-basic        | o               |     |
| helloworld        | o               |     |
| idle-basic        | o               |     |
| uvcat             | o               |     |
| uvtee             | o               |     |
| onchange          | o               |     |
| tcp-echo-server   | o               |     |
| udp-dhcp          | o               |     |
| dns               | o               |     |
| interfaces        | o               |     |
| thread-create     | c               |     |
| locks             | uv_barrier_wait |
| queue-work        | `<unistd.h>`    |
| queue-cancel      | `<unistd.h>`    |
| progress          | `<unistd.h>`    |
| spawn             | o               |     |
| detach            | o               |     |
| signal            | `<unistd.h>`    |
| proc-streams      | o               |     |
| cgi               | o               |     | and cgi/tick       |
| pipe-echo-server  | o               |     |
| multi-echo-server | o               |     |
| uvstop            | o               |     |
| ref-timer         | o               |     |
| idle-compute      | o               |     |
| uvwget            | `<curl.h>`      |     |
| plugin            | o               |     | and plugin/hello.c |
| tty               | o               |     |
| tty-gravity       | o               |     |
