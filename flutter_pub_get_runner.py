import subprocess, os

# Delete temp file if exists
tmp = r'c:\Users\LAB\Documents\smartclasscheckin\run_flutter_pub_get.py'
if os.path.exists(tmp):
    os.remove(tmp)
    print("Deleted temp file")

result = subprocess.run(
    ["flutter", "pub", "get"],
    cwd=r"c:\Users\LAB\Documents\smartclasscheckin",
    capture_output=True, text=True, timeout=180
)
print("STDOUT:", result.stdout)
print("STDERR:", result.stderr)
print("Return code:", result.returncode)
