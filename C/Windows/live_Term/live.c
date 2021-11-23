#include "GPIB_prof.h"
#include "serial.h"
#include "commands.h"

#include <string.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>
#include <windows.h>

const struct com read_com = {4, {"OPC?;PRES;\r", "OPC?;WAIT;\r", "CORRON;\r", "OPC?;SING;\r"}};
const struct com num_com = {3, {"STAR", "STOP", "POIN"}};

int main(int argc, char *argv[])
{
    HANDLE fd;
    int ret;
    char *buff = NULL;
    char *read_buff = NULL;
    int i;
    bool write = 0;
    bool dat_flag = 0;
    int fin = 0;
    char *numb = NULL;
    char *rem = NULL;
    int star;
    int stop;
    int poin;
    char *dat = NULL;
    int fc = 0;
    char *file = NULL;
    FILE *temp;
    FILE *f;

    rem = malloc(256);
    if (rem == NULL)
    {
        perror("memory error");
        goto fail;
    }
    numb = malloc(4);
    if (numb == NULL)
    {
        perror("memory error");
        goto fail;
    }
    buff = malloc(256);
    if (buff == NULL)
    {
        perror("memory error");
        goto fail;
    }
    read_buff = malloc(1);
    if (read_buff == NULL)
    {
        perror("memory error");
        goto fail;
    }
    file = malloc(5);
    if (file == NULL)
    {
        perror("memory error");
        goto fail;
    }

    if (argc < 3)
    {
        printf("Usage: %s [serial device] [baud rate]", argv[0]);
        goto fail;
    }

    fd = open_port(argv[1], atoi(argv[2]));
    if (fd < 0)
        goto fail;

    ret = GPIB_conf(fd, 0);
    if (ret < 0)
        goto fail;

    while (fin == 0)
    {
        write = 0;
        scanf("%s", buff);
        strcat(buff, "\r");
        if (dat_flag == 1) {
            poin = atoi(buff);
            dat = malloc(50 * poin);
            if (dat == NULL)
            {
                perror("memory error");
                goto fail;
            } else {
                memset(dat, 0, strlen(dat));
                printf("dat malloc success, poin: %d\n", poin);
            }
            write = 1;
            dat_flag = 0;
        }
        printf("buff len: %I64d\n", strlen(buff));
        for (i = 0; i < strlen(buff); i++)
        {
            if (i < 4)
            {
                numb[i] = buff[i];
                printf("numb[%d]: %c\n", i, numb[i]);
            }
            else
            {
                rem[i - 4] = buff[i];
                printf("rem[%d]: %c\n", i-4, rem[i-4]);
            }
        }
        if (strcmp(numb, "OUTP") == 0)
        {
            ret = write_port(fd, buff, strlen(buff));
            if (ret < 0)
                goto fail;
            write = 1;
            ret = read_port(fd, dat, 50 * poin);
            if (ret < 0)
                goto fail;
            else {
                ret = sprintf(file, "data%d", fc);
                if (ret < 0)
                    goto fail;
                temp = fopen(file, "w+");
                if (temp == NULL)
                {
                    perror("failed to open file");
                    fclose(temp);
                    goto fail;
                }
                fclose(temp);
                ret = remove(file);
                if (ret != 0)
                {
                    perror("failed to remove file");
                    goto fail;
                }
                f = fopen(file, "w");
                if (f == NULL)
                {
                    perror("failed to open file");
                    fclose(f);
                    goto fail;
                }

                for (i = 0; i < (50 * poin); i++)
                {
                    ret = fprintf(f, "%c", dat[i]);
                    if (ret < 0)
                    {
                        printf("dat error\n");
                        fclose(f);
                        goto fail;
                    }
                }
                fprintf(f, "\nSTAR%dSTOP%dPOIN%d", star, stop, poin);
                fclose(f);
                fin++;
                fc++;
            }
        }
        if (write == 0)
        {
            for (i = 0; i < read_com.num; i++)
            {
                if (strcmp(buff, read_com.check[i]) == 0)
                {
                    ret = write_port(fd, buff, strlen(buff));
                    if (ret < 0)
                        goto fail;
                    ret = read_port(fd, read_buff, 1);
                    if (ret < 0)
                        goto fail;
                    printf("Read success\n");
                    write = 1;
                    break;
                }
            }
        }
        if (write == 0)
        {
            for (i = 0; i < num_com.num; i++)
            {
                if (strcmp(numb, num_com.check[i]) == 0)
                {
                    ret = write_port(fd, buff, strlen(buff));
                    if (ret < 0)
                        goto fail;
                    write = 1;
                    if (strcmp(numb, "STAR") == 0)
                    {
                        star = atoi(rem);
                    }
                    else if (strcmp(numb, "STOP") == 0)
                    {
                        stop = atoi(rem);
                    }
                    else if (strcmp(numb, "POIN") == 0)
                    {
                        dat_flag = 1;
                    }
                    break;
                }
            }
            if (write == 0)
            {
                ret = write_port(fd, buff, strlen(buff));
                if (ret < 0)
                    goto fail;
                write = 1;
            }
        }
    }

    free(rem);
    free(numb);
    free(buff);
    free(read_buff);
    free(file);
    free(dat);
    return 0;

fail:
    free(rem);
    free(numb);
    free(buff);
    free(read_buff);
    free(file);
    free(dat);
    return -1;
}