@cffi.link("uv")  // link against libuv
module uv

// Define a pointer type for uv_loop_t
extern struct uv_loop_t:
    pass  // You can leave opaque structs empty unless you need fields

// Define the init, run, and default loop functions
extern fn uv_loop_init(loop: Pointer[uv_loop_t]) -> Int32
extern fn uv_default_loop() -> Pointer[uv_loop_t]
extern fn uv_run(loop: Pointer[uv_loop_t], mode: Int32) -> Int32

const UV_RUN_DEFAULT: Int32 = 0

fn main():
    let loop = uv_default_loop()
    let result = uv_run(loop, UV_RUN_DEFAULT)
    print("uv_run exited with: ", result)


