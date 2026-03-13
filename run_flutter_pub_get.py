import subprocess, os
result = subprocess.run(
    ["flutter", "pub", "get"],
    cwd=r"c:\Users\LAB\Documents\smartclasscheckin",
    capture_output=True, text=True, timeout=120
)
print("STDOUT:", result.stdout)
print("STDERR:", result.stderr)
print("Return code:", result.returncode)
