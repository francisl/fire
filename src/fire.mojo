from python import Python
from file_watcher import watch_directory, get_directory_from_path
import sys

fn main() raises:
    var args = sys.argv()
    
    if len(args) < 2:
        print("Fire - Mojo File Watcher")
        print()
        print("Usage: fire <target_mojo_file>")
        print("Example: fire src/main.mojo")
        print()
        print("This will watch the directory containing the target file")
        print("and automatically recompile when .mojo or .py files change.")
        return

    if args[1] == "--version" or args[1] == "-v":
        print("Fire - Mojo File Watcher")
        print("Version 0.0.6")
        return

    var target_file = args[1]
    var watch_directory_path = get_directory_from_path(target_file)
    
    # Verify target file exists
    var os = Python.import_module("os")
    if not os.path.exists(target_file):
        print("❌ Error: Target file does not exist:", target_file)
        return
    
    if not target_file.endswith(".mojo"):
        print("❌ Error: Target file must be a .mojo file")
        return
    
    watch_directory(target_file, watch_directory_path, 1)

