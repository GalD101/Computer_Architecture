'''
Generate 100 basic files
'''
header_template = """
        #ifndef FILE_{0}_H
        #define FILE_{0}_H

        void func{0}(void);

        #endif
    """

src_template = """
        #include "file_{0}.h"

        void func{0}(void) {{
            printf("Hello World! func{0}\\n");
        }}
    """
    
for i in range(100):
    with open("file_" + str(i) + ".h", "w") as f:
        f.write(header_template.format(i))
    with open("file_" + str(i) + ".c", "w") as f:
        f.write(src_template.format(i))
        
        
'''
Create main.c
'''
main_src = "#include <stdio.h>\n"
main_src += "".join([f'#include "file_{i}.h"\n' for i in range(100)])
main_src += "int main(void) {\n"
main_src += "".join([f'\tfunc{i}();\n' for i in range(100)])
main_src += "}"

with open("main.c", "w") as f:
    f.write(main_src)
