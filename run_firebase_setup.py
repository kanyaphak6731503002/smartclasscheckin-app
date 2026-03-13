import subprocess

def run(cmd, timeout=120):
    print(f"\n>>> Running: {cmd}")
    r = subprocess.run(cmd, capture_output=True, text=True, shell=True, timeout=timeout)
    print("STDOUT:", r.stdout.strip())
    print("STDERR:", r.stderr.strip())
    print("Return code:", r.returncode)
    return r.returncode

# Check if npm is available
run("npm --version", timeout=15)
run("node --version", timeout=15)

# Install Firebase CLI globally
run("npm install -g firebase-tools", timeout=180)

# Verify installation
run("firebase --version", timeout=15)
