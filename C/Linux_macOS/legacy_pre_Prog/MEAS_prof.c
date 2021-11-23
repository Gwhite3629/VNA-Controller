#include "serial.h"
#include "DATA_prof.h"
#include <stdlib.h>
#include <stdio.h>

int test_MEAS(int fd)
{
	char *buf;
	char *start;
	char *stop;
	int ret;
	int fstart;
	int fstop;

	start = malloc(12 * sizeof(char));
	if (start == NULL)
	{
		perror("memory error");
		goto fail;
	}
	stop = malloc(12 * sizeof(char));
	if (stop == NULL)
	{
		perror("memory error");
		goto fail;
	}

	buf = malloc(1);
	if (buf == NULL)
	{
		perror("memory error");
		goto fail;
	}

	// Initialize
	ret = write_port(fd, "OPC?;PRES;\r", 11);
	if (ret < 0)
		goto fail;
	ret = read_port(fd, buf, 1);
	if (ret < 0)
		goto fail;

	// Set up Channel 1
	ret = write_port(fd, "CHAN1;\r", 7);
	if (ret < 0)
		goto fail;
	//ret = write_port(fd, "AUXCOFF;", 8);
	//if (ret<0) goto fail;
	ret = write_port(fd, "S11;\r", 5);
	if (ret < 0)
		goto fail;
	ret = write_port(fd, "LOGM;\r", 6);
	if (ret < 0)
		goto fail;

	// Set up Channel 2
	ret = write_port(fd, "CHAN2;\r", 7);
	if (ret < 0)
		goto fail;
	//ret = write_port(fd, "AUXCOFF;", 8);
	//if (ret<0) goto fail;
	ret = write_port(fd, "S11;\r", 5);
	if (ret < 0)
		goto fail;
	ret = write_port(fd, "PHAS;\r", 6);
	if (ret < 0)
		goto fail;

	// Set up Display
	ret = write_port(fd, "DUACON;\r", 8);
	if (ret < 0)
		goto fail;

	// Request and input start freq
	printf("Input start frequency (MHz):");
	scanf("%d", &fstart);
	ret = sprintf(start, "STAR%dMHZ;\r", fstart);
	if (ret < 0)
	{
		perror("memory error");
		goto fail;
	}
	ret = write_port(fd, start, ret);
	if (ret < 0)
		goto fail;

	// Request and input stop freq
	printf("Input stop frequency (MHz):");
	scanf("%d", &fstop);
	ret = sprintf(stop, "STOP%dMHZ;\r", fstop);
	if (ret < 0)
	{
		perror("memory error");
		goto fail;
	}
	ret = write_port(fd, stop, ret);
	if (ret < 0)
		goto fail;

	// Autoscale displays
	ret = write_port(fd, "CHAN1;AUTO;\r", 12);
	if (ret < 0)
		goto fail;
	ret = write_port(fd, "CHAN2;AUTO;\r", 12);
	if (ret < 0)
		goto fail;

	ret = test_DATA(fd, "data");
	if (ret < 0)
		return -1;

	/*
	// Turn on auxiliary channels
	ret = write_port(fd, "CHAN1;AUXCON;", 13);
	if (ret<0) goto fail;
	ret = write_port(fd, "CHAN2;AUXCON;", 13);
	if (ret<0) goto fail;

	// Channel 2 insertion loss measurment
	ret = write_port(fd, "S21;", 4);
	if (ret<0) goto fail;
	ret = write_port(fd, "LOGM;AUTO;", 10);
	if (ret<0) goto fail;

	// Channel 3 reflected power measurement
	ret = write_port(fd, "CHAN3;MEASA;", 12);
	if (ret<0) goto fail;
	ret = write_port(fd, "LOGM;AUTO;", 10);
	if (ret<0) goto fail;

	// Channel 4 transmitted power measurement
	ret = write_port(fd, "CHAN4;MEASB;", 12);
	if (ret<0) goto fail;
	ret = write_port(fd, "LOGM;AUTO;", 10);
	if (ret<0) goto fail;

	// Display four seperate
	ret = write_port(fd, "SPLID4;", 7);
	if (ret<0) goto fail;
	
	// Return local control
	ret = write_port(fd, "OPC?;WAIT;", 10);
	if (ret<0) goto fail;
	ret = read_port(fd, buf, 1);
	if (ret<0) goto fail;
	*/
	free(start);
	free(stop);
	free(buf);
	return 0;
fail:
	free(start);
	free(stop);
	free(buf);
	return -1;
}

int large_MEAS(int fd)
{
	char *buf;
	char *start;
	char *stop;
	int ret;
	int fstart;
	int fstop;

	start = malloc(12 * sizeof(char));
	if (start == NULL)
	{
		perror("memory error");
		goto fail;
	}
	stop = malloc(12 * sizeof(char));
	if (stop == NULL)
	{
		perror("memory error");
		goto fail;
	}

	buf = malloc(1);
	if (buf == NULL)
	{
		perror("memory error");
		goto fail;
	}

	// Initialize
	ret = write_port(fd, "OPC?;PRES;\r", 11);
	if (ret < 0)
		goto fail;
	ret = read_port(fd, buf, 1);
	if (ret < 0)
		goto fail;

	// Set up Channel 1
	ret = write_port(fd, "CHAN1;\r", 7);
	if (ret < 0)
		goto fail;
	//ret = write_port(fd, "AUXCOFF;", 8);
	//if (ret<0) goto fail;
	ret = write_port(fd, "S11;\r", 5);
	if (ret < 0)
		goto fail;
	ret = write_port(fd, "LOGM;\r", 6);
	if (ret < 0)
		goto fail;

	// Set up Channel 2
	ret = write_port(fd, "CHAN2;\r", 7);
	if (ret < 0)
		goto fail;
	//ret = write_port(fd, "AUXCOFF;", 8);
	//if (ret<0) goto fail;
	ret = write_port(fd, "S11;\r", 5);
	if (ret < 0)
		goto fail;
	ret = write_port(fd, "PHAS;\r", 6);
	if (ret < 0)
		goto fail;

	// Set up Display
	ret = write_port(fd, "DUACON;\r", 8);
	if (ret < 0)
		goto fail;

	// Request and input start freq
	printf("Input start frequency (MHz):");
	scanf("%d", &fstart);
	ret = sprintf(start, "STAR%dMHZ;\r", fstart);
	if (ret < 0)
	{
		perror("memory error");
		goto fail;
	}
	ret = write_port(fd, start, ret);
	if (ret < 0)
		goto fail;

	// Request and input stop freq
	printf("Input stop frequency (MHz):");
	scanf("%d", &fstop);
	ret = sprintf(stop, "STOP%dMHZ;\r", fstop);
	if (ret < 0)
	{
		perror("memory error");
		goto fail;
	}
	ret = write_port(fd, stop, ret);
	if (ret < 0)
		goto fail;

	// Autoscale displays
	ret = write_port(fd, "CHAN1;AUTO;\r", 12);
	if (ret < 0)
		goto fail;
	ret = write_port(fd, "CHAN2;AUTO;\r", 12);
	if (ret < 0)
		goto fail;

	// Turn on auxiliary channels
	//ret = write_port(fd, "CHAN1;AUXCON;", 13);
	//if (ret<0) goto fail;
	//ret = write_port(fd, "CHAN2;AUXCON;", 13);
	//if (ret<0) goto fail;

	// Channel 2 insertion loss measurment
	ret = write_port(fd, "S21;\r", 4);
	if (ret < 0)
		goto fail;
	ret = write_port(fd, "LOGM;AUTO;\r", 10);
	if (ret < 0)
		goto fail;

	// Channel 3 reflected power measurement
	ret = write_port(fd, "CHAN1;MEASA;\r", 12);
	if (ret < 0)
		goto fail;
	ret = write_port(fd, "LOGM;AUTO;\r", 10);
	if (ret < 0)
		goto fail;

	// Channel 4 transmitted power measurement
	ret = write_port(fd, "CHAN2;MEASB;\r", 12);
	if (ret < 0)
		goto fail;
	ret = write_port(fd, "LOGM;AUTO;\r", 10);
	if (ret < 0)
		goto fail;

	ret = test_DATA(fd, "data");
	if (ret < 0)
		return -1;

	// Display four seperate
	ret = write_port(fd, "SPLID4;\r", 7);
	if (ret < 0)
		goto fail;

	// Return local control
	ret = write_port(fd, "OPC?;WAIT;", 10);
	if (ret < 0)
		goto fail;
	ret = read_port(fd, buf, 1);
	if (ret < 0)
		goto fail;

	free(start);
	free(stop);
	free(buf);
	return 0;
fail:
	free(start);
	free(stop);
	free(buf);
	return -1;
}
