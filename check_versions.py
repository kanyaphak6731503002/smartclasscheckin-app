import subprocess

def run(cmd):
    r = subprocess.run(cmd, capture_output=True, text=True, shell=True, timeout=30)
    print(f"CMD: {cmd}")
    print(f"OUT: {r.stdout.strip()}")
    print(f"ERR: {r.stderr.strip()}")
    print()

run("firebase --version")
run("flutter --version")
run("node --version")
run("npm --version")
