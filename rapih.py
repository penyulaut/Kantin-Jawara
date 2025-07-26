import os
import re


def comment_print_in_dart_files(lib_dir='lib'):
    for root, _, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                with open(file_path, 'r', encoding='utf-8') as f:
                    lines = f.readlines()

                updated_lines = []
                inside_multiline_print = False
                multiline_buffer = []
                indent = 0

                for line in lines:
                    stripped = line.strip()

                    # Hapus line jika hanya diawali dengan "// "
                    if re.fullmatch(r'\s*// .*', line):
                        continue

                    if not inside_multiline_print and stripped.startswith('print('):
                        if stripped.endswith(');'):
                            indent = len(line) - len(line.lstrip())
                            updated_lines.append(
                                ' ' * indent + '// ' + stripped + '\n')
                        else:
                            inside_multiline_print = True
                            indent = len(line) - len(line.lstrip())
                            multiline_buffer = [line]
                    elif inside_multiline_print:
                        multiline_buffer.append(line)
                        if stripped.endswith(');'):
                            for buffered_line in multiline_buffer:
                                updated_lines.append(
                                    ' ' * indent + '// ' + buffered_line.lstrip())
                            inside_multiline_print = False
                            multiline_buffer = []
                    else:
                        updated_lines.append(line)

                with open(file_path, 'w', encoding='utf-8') as f:
                    f.writelines(updated_lines)


comment_print_in_dart_files()
