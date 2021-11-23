#include "GPIB_prof.h"
#include "DATA_prof.h"
#include "MEAS_prof.h"

int GPIB_sel(int fd, int profile)
{
	int ret;

	switch (profile)
	{
	case 0:
		ret = def(fd);
		if (ret < 0)
			goto fail;
	}
	return 0;
fail:
	return -1;
}

int MEAS_sel(int fd, int profile)
{


fail:
    return -1;
}

int DATA_sel(int fd, int profile)
{


fail:
    return -1;
}