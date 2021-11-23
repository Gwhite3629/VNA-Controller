#include "serial.h"
#include "selector.h"
#include <fcntl.h>
#include <stdint.h>
#include <stddef.h>
#include <unistd.h>

int main(int argc, char *argv[])
{
	int fd;
	int ret;

	if (argc < 3)
    {
        printf("Usage: %s [serial device] [baud rate]", argv[0]);
        return -1;
    }

    fd = open_port(argv[1], atoi(argv[2]));
    if (fd < 0)
        return -1;

	ret = GPIB_sel(fd, 0);
	if (ret < 0)
		return -1;

	ret = MEAS_sel(fd, 0);
	if (ret < 0)
		return -1;

	ret = DATA_sel(fd, 0);
	if (ret < 0)
		return -1;

	close(fd);

	return 0;
}
