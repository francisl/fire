from python import Python, PythonObject
from time import sleep
import sys

fn get_mtime(path: String) raises -> Float64:
    var os = Python.import_module("os")
    var stat_result = os.stat(path)
    return Float64(stat_result.st_mtime)

fn find_source_files(directory: String) raises -> PythonObject:
    """Find all .mojo and .py files in the directory."""
    var os = Python.import_module("os")
    var files = Python.list()
    
    var entries = os.listdir(directory)
    for entry in entries:
        var entry_str = String(entry)
        var full_path = directory + "/" + entry_str
        
        # Check if it's a file and has .mojo or .py extension
        if os.path.isfile(full_path):
            if entry_str.endswith(".mojo") or entry_str.endswith(".py"):
                files.append(full_path)
    
    return files

fn get_files_mtimes(files: PythonObject) raises -> PythonObject:
    """Get modification times for a list of files."""
    var mtimes = Python.dict()
    
    for file_path in files:
        var file_str = String(file_path)
        try:
            var mtime = get_mtime(file_str)
            mtimes[file_path] = mtime
        except:
            # Skip files that can't be accessed
            pass
    
    return mtimes

fn get_directory_from_path(file_path: String) -> String:
    """Extract directory from file path."""
    var last_slash = -1
    for i in range(len(file_path)):
        if file_path[i] == "/":
            last_slash = i
    
    if last_slash == -1:
        return "."
    else:
        return file_path[:last_slash]

fn run_mojo_command(target_file: String) raises:
    """Run mojo compilation command."""
    var subprocess = Python.import_module("subprocess")
    var command = Python.list()
    command.append("mojo")
    command.append(target_file)
    
    print("Running: mojo", target_file)
    print("-" * 50)
    
    try:
        var result = subprocess.run(command, capture_output=True, text=True)
        
        # Print stdout if there's any output
        var stdout = String(result.stdout)
        if len(stdout) > 0:
            print(stdout)
        
        # Print stderr if there are any errors
        var stderr = String(result.stderr)
        if len(stderr) > 0:
            print("Error output:")
            print(stderr)
        
        var return_code = Int(result.returncode)
        if return_code == 0:
            print("✅ Compilation successful")
        else:
            print("❌ Compilation failed with exit code:", return_code)
    except e:
        print("❌ Failed to run mojo command:", e)
    
    print("-" * 50)
    print()

fn watch_directory(target_file: String, directory: String, interval: Int) raises:
    print("Fire - Mojo File Watcher")
    print("Target file:", target_file)
    print("Watching directory:", directory)
    print("Monitoring .mojo and .py files for changes...")
    print()
    
    var files = find_source_files(directory)
    var last_mtimes = get_files_mtimes(files)
    
    print("Found", len(files), "source files to monitor:")
    for file_path in files:
        print("  -", file_path)
    print()
    
    # Run initial compilation
    run_mojo_command(target_file)

    while True:
        sleep(Float64(interval))
        
        # Re-scan for new files
        var current_files = find_source_files(directory)
        var current_mtimes = get_files_mtimes(current_files)
        
        var files_changed = False
        
        # Check for new files
        if len(current_files) != len(files):
            print("Directory structure changed - rescanning...")
            files = current_files
            for file_path in files:
                if file_path not in last_mtimes:
                    print("New file detected:", file_path)
                    files_changed = True
        
        # Check for modified files
        for file_path in current_files:
            var file_str = String(file_path)
            if file_path in current_mtimes:
                var current_mtime = current_mtimes[file_path]
                if file_path not in last_mtimes or current_mtime != last_mtimes[file_path]:
                    print("File changed:", file_str)
                    files_changed = True
        
        # If any files changed, recompile
        if files_changed:
            run_mojo_command(target_file)
        
        last_mtimes = current_mtimes

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

