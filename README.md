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
```

| name       | c   | zig |
| ---------- | --- | --- |
| helloworld | o   | o   |
