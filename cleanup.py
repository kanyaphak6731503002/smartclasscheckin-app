#!/usr/bin/env python
import os

base_path = r'c:\Users\LAB\Documents\smartclasscheckin'
temp_files = [
    os.path.join(base_path, 'check_versions.py'),
    os.path.join(base_path, 'flutter_pub_get_runner.py'),
    os.path.join(base_path, 'run_flutter_pub_get.py')
]

for temp_file in temp_files:
    if os.path.exists(temp_file):
        os.remove(temp_file)
        print(f'✓ Deleted: {temp_file}')
    else:
        print(f'✓ Not found (skipped): {temp_file}')

print('')
print('SUCCESS')
