#ifndef _SERIAL_H_
#define _SERIAL_H_

#include <stdint.h>
#include <stddef.h>
#include "GPIB_prof.h"

int open_port (const char *dev, uint32_t baud);
int read_port (int fd, char *buf, size_t size);
int write_port (int fd, const char *buf, size_t size);
int GPIB_conf (int fd, int profile);

#endif
