from python import Python, PythonObject
from time import sleep
from process_manager import start_mojo_process_background, check_process_status

fn get_mtime(path: String) raises -> Float64:
    var os = Python.import_module("os")
    var stat_result = os.stat(path)
    return Float64(stat_result.st_mtime)

fn find_source_files(directory: String) raises -> PythonObject:
    """Find all .mojo and .py files in the directory and all subdirectories."""
    var os = Python.import_module("os")
    var files = Python.list()
    
    # Use os.walk to recursively traverse all subdirectories
    for walk_tuple in os.walk(directory):
        var dirpath = walk_tuple[0]
        var dirnames = walk_tuple[1]
        var filenames = walk_tuple[2]
        
        for filename in filenames:
            var filename_str = String(filename)
            if filename_str.endswith(".mojo") or filename_str.endswith(".py"):
                var full_path = String(dirpath) + "/" + filename_str
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
    start_mojo_process_background(target_file)

    while True:
        sleep(Float64(interval))
        
        # Check process status
        check_process_status()
        
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
        
        # If any files changed, restart the process
        if files_changed:
            start_mojo_process_background(target_file)
        
        last_mtimes = current_mtimes 