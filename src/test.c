#include "libasmio.h"

int main(void) {
    char name[20];
    char comp_name[] = "Chrubuntu";
    char a[] = "a";
    char b[] = "b";
    char c[] = "c";
    char d[] = "d";
    char e[] = "e";

   asmio_printf("What's your name?\n");
   asmio_gets(name, 20);

   asmio_printf("Hello, %s! I'm %s!\n", name, comp_name);

   asmio_printf("This is a test of varargs > 5\n");
   asmio_printf("%s %s %s %s %s %s %s %s %s %s\n",
                 a, b, c, d, e, a, b, c, d, e);

    double z = 1.0;
    asmio_printf("Hello! %f %f %f %f %f %f %f %f %f %f %f %f\n",
                         z, z, z, z, z, z, z, z, z, z, z, z);
}
