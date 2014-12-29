#ifndef LIBASMIO_H
#define LIBASMIO_H
#include <stdint.h>
void asmio_gets(const char *buf, uint64_t len);
void asmio_printf(const char *format, ...);
#endif
