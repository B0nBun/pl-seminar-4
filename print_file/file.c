/* file.c */

#include <stdio.h>

extern void print_file(char* file_name);
extern void print_string(char* s);

int main() {
    char buffer[1000] = {0};
    print_string("Enter filepath:");
    int _ = scanf("%s", buffer);
    (void) _;
    print_file(buffer);
    return 0;
}

