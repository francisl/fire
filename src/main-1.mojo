import sys.ffi

struct uv_loop_t { /* opaque */ }
struct uv_fs_event_t { /* opaque */ }

fn uv_loop_new() -> *uv_loop_t = external_call["uv_loop_new", *uv_loop_t]()
fn uv_loop_run(loop: *uv_loop_t, mode: c_int) -> c_int = external_call["uv_run", c_int, *uv_loop_t, c_int]()
fn uv_fs_event_init(loop: *uv_loop_t, handle: *uv_fs_event_t, path: c_char_ptr, cb: usize, flags: c_uint) -> c_int = 
    external_call["uv_fs_event_init", c_int, *uv_loop_t, *uv_fs_event_t, c_char_ptr, usize, c_uint]()

fn main():
    let loop = uv_loop_new()
    var fs_evt: uv_fs_event_t = ...
    let status = uv_fs_event_init(loop, &fs_evt, "myfile.txt".c_str(), usize(file_changed_cb), 0)
    assert status == 0

    uv_loop_run(loop, 0)

fn file_changed_cb(handle: *uv_fs_event_t, filename: *c_char, events: c_int, status: c_int):
    print("Changed: {filename.decode()}, events={events}, status={status}")


