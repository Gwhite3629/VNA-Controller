#include "serial.h"
#include <stdio.h>
#include <stdlib.h>

int test_DATA(int fd, char *file) {
  int ret;
  char *buf;
  int NUMPOINTS;
  char *dat;
  char *points;
  FILE *temp;
  FILE *f;
  int i;

  NUMPOINTS = 201;

  temp = fopen(file, "w+");
  if (temp == NULL) {
    perror("failed to open file");
    goto fail;
  }
  fclose(temp);
  ret = remove(file);
  if (ret != 0) {
    perror("failed to remove file");
    goto fail;
  }

  f = fopen(file, "w");
  if (f == NULL) {
    perror("failed to open file");
    goto fail;
  }

  points = malloc(8);
  if (points == NULL) {
    perror("memory error");
    goto fail;
  }

  buf = malloc(4);
  if (buf == NULL) {
    perror("memory error");
    goto fail;
  }

  dat = malloc(50 * NUMPOINTS * sizeof(char));
  if (dat == NULL) {
    perror("memory error");
    goto fail;
  }

  /*
  // Initialize
  ret = write_port(fd, "OPC?;PRES;", 10);
  if (ret<0) goto fail;
  ret = read_port(fd, buf, 1);
  if (ret<0) goto fail;
  */
  ret = sprintf(points, "POIN %d;\r", NUMPOINTS);
  if (ret < 0)
    goto fail;
  ret = write_port(fd, points, 10);
  if (ret < 0)
    goto fail;

  // Setup
  ret = write_port(fd, "OPC?;SING;\r", 10);
  if (ret < 0)
    goto fail;
  ret = read_port(fd, buf, 2);
  if (ret < 0)
    goto fail;
  ret = write_port(fd, "FORM4;\r", 7);
  if (ret < 0)
    goto fail;
  ret = write_port(fd, "CORRON;\r", 8);
  if (ret < 0)
    goto fail;
  ret = read_port(fd, buf, 3);
  if (ret < 0)
    goto fail;
  ret = write_port(fd, "OUTPDATA;\r", 10);
  if (ret < 0)
    goto fail;

  ret = read_port(fd, dat, 50 * NUMPOINTS);
  if (ret < 0)
    goto fail;

  for (i = 0; i < (50 * NUMPOINTS); i++) {
    ret = fprintf(f, "%c", dat[i]);
  }

  // ret = write_port(fd, "OPC?;WAIT;\r", 11);
  // if (ret<0) goto fail;
  // ret = read_port(fd, buf, 2);
  // if (ret<0) goto fail;

  fclose(f);
  free(dat);
  free(buf);
  free(points);
  return 0;
fail:
  fclose(f);
  free(dat);
  free(buf);
  free(points);
  return -1;
}
