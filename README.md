# zig から libuv する

`@cImport` するとうまくいかないので手を考える。

## dependencies

```sh
zig fetch --save=libuv git+https://github.com/libuv/libuv.git#v1.48.0
```
