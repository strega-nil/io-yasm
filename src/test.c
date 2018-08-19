#include "libasmio.h"

#define NAME_SIZE 40

int main(void) {
   char name[NAME_SIZE];
   char const comp_name[] = "Chrubuntu";
   char const a[] = "a";
   char const b[] = "b";
   char const c[] = "c";
   char const d[] = "d";
   char const e[] = "e";

   asmio_printf("What's your name?\n");
   asmio_gets(name, NAME_SIZE);

   asmio_printf("Hello, %s! I'm %s!\n", name, comp_name);

   asmio_printf("This is a test of varargs > 5\n");
   asmio_printf("%s %s %s %s %s %s %s %s %s %s\n",
                 a, b, c, d, e, a, b, c, d, e);

    double z = 1.0;
    asmio_printf("Hello! %f %f %f %f %f %f %f %f %f %f %f %f\n",
                         z, z, z, z, z, z, z, z, z, z, z, z);

    asmio_printf("Mix floats (%f), ints (%d), and %s\n", z, 23, "strings");
}
