import os
import time

fn get_mtime(path: String) -> Int:
    var stat_result = os.stat(path)
    return stat_result.st_mtime

fn watch_file(path: String, interval: Int):
    var last_mtime = get_mtime(path)
    print("Watching file: " + path)

    while 1 == 1:
        time.sleep(interval)
        var current_mtime = get_mtime(path)
        if current_mtime != last_mtime:
            print("File changed: " + path)
            last_mtime = current_mtime

fn main():
    watch_file("example.txt", 1)


