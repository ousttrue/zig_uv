pub const Loop = extern struct {};

// struct uv_loop_s {
//   /* User data - use this for whatever. */
//   void* data;
//   /* Loop reference counting. */
//   unsigned int active_handles;
//   void* handle_queue[2];
//   union {
//     void* unused;
//     unsigned int count;
//   } active_reqs;
//   /* Internal storage for future extensions. */
//   void* internal_fields;
//   /* Internal flag to signal loop stop. */
//   unsigned int stop_flag;
//   UV_LOOP_PRIVATE_FIELDS
// };
pub const Tty = extern struct {
    data: *anyopaque,
};

// UV_EXTERN uv_loop_t* uv_default_loop(void);
pub extern fn uv_default_loop() *Loop;

pub const RunMode = enum(c_int) { DEFAULT = 0, ONCE, NOWAIT };

pub extern fn uv_run(_: *anyopaque, mode: RunMode) c_int;

pub extern fn uv_tty_init(_: *Loop, _: *Tty, fd: c_int, readable: c_int) c_int;
