
import os

file_path = 'app/migrations/0001_initial.py'
lines = open(file_path, 'r').readlines()
new_lines = []
skip = False
buffer = []

for line in lines:
    # Check for start of CreateModel
    if 'migrations.CreateModel(' in line:
        # If we were already buffering (nested? shouldn't happen), flush
        if buffer:
            new_lines.extend(buffer)
            buffer = []
        buffer.append(line)
        continue
    
    if buffer:
        buffer.append(line)
        # Check if this block is for Conversation or Message
        if "name='Conversation'" in line or "name='Message'" in line:
            skip = True
        
        # Check for end of block (8 spaces indentation + ),)
        # We need to be careful with matching the closing parenthesis
        if line.startswith('        ),'):
            if not skip:
                new_lines.extend(buffer)
            else:
                print("Skipped a model block")
            buffer = []
            skip = False
        continue
    
    new_lines.append(line)

# Flush any remaining buffer (shouldn't be any)
if buffer:
    new_lines.extend(buffer)

with open(file_path, 'w') as f:
    f.writelines(new_lines)
