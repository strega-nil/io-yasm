#include "libasmio.h"

int main(void) {
    char name[20];
    char comp_name[] = "Chrubuntu";

    asmio_printf("What's your name?\n");
    asmio_gets(name, 20);

    asmio_printf("Hello, %s! I'm %s!\n", name, comp_name);
}
