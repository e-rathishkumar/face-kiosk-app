import os
import re

def process_file(filepath):
    with open(filepath, 'r') as f:
        content = f.read()

    # Regex to find dayjs(something) but not dayjs()
    # We want to replace dayjs(var) with dayjs(typeof var === 'string' && !var.endsWith('Z') ? var + 'Z' : var)
    # We need to be careful not to replace already fixed ones or dayjs()
    
    def replacer(match):
        inner = match.group(1)
        if not inner.strip():
            return match.group(0) # dayjs()
        if "endsWith" in inner or "typeof" in inner:
            return match.group(0) # Already fixed
        return f"dayjs(typeof {inner} === 'string' && !{inner}.endsWith('Z') ? {inner} + 'Z' : {inner})"

    new_content = re.sub(r'dayjs\(([^)]*)\)', replacer, content)

    if new_content != content:
        with open(filepath, 'w') as f:
            f.write(new_content)
        print(f"Fixed {filepath}")

for root, _, files in os.walk('admin_portal/src'):
    for file in files:
        if file.endswith('.tsx') or file.endswith('.ts'):
            process_file(os.path.join(root, file))

