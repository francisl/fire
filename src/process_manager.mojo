from python import Python, PythonObject
from time import sleep

# Global variable to track the running process
var running_process: PythonObject = Python.none()

fn kill_running_process() raises:
    """Kill the currently running process if it exists."""
    if running_process != Python.none():
        try:
            var poll_result = running_process.poll()
            if poll_result == Python.none():  # Process is still running
                print("🔄 Terminating previous process...")
                running_process.terminate()
                # Wait a bit for graceful termination
                sleep(0.1)
                # Force kill if still running
                var poll_result_after = running_process.poll()
                if poll_result_after == Python.none():
                    running_process.kill()
                    print("🔪 Force killed previous process")
        except:
            pass  # Process might have already terminated

fn start_mojo_process_background(target_file: String) raises:
    """Start a new mojo process in the background."""
    # Kill any existing process
    kill_running_process()
    
    var subprocess = Python.import_module("subprocess")
    var command = Python.list()
    command.append("mojo")
    command.append("run")
    command.append(target_file)
    
    print("🚀 Starting: mojo", target_file)
    print("-" * 50)
    
    try:
        # Start process in the background with output flowing directly to terminal
        running_process = subprocess.Popen(command)
        print("✅ Process started in background (PID:", running_process.pid, ")")
        
    except e:
        print("❌ Failed to start mojo command:", e)
    
    print("-" * 50)
    print()

fn check_process_status() raises:
    """Check and display the status of the running process."""
    if running_process != Python.none():
        var poll_result = running_process.poll()
        if poll_result != Python.none():
            # Process has terminated
            var return_code = Int(poll_result)
            if return_code == 0:
                print("✅ Process completed successfully")
            else:
                print("❌ Process failed with exit code:", return_code)
            
            print("-" * 50)
            print()
            
            # Clear the process reference
            running_process = Python.none() 