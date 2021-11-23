#include "GPIB_prof.h"
#include "serial.h"
#include "commands.h"

#include <string.h>
#include <stdbool.h>
#include <stdlib.h>
#include <stdio.h>

const struct com num_com = {3, {"STAR", "STOP", "POIN"}};

int main(int argc, char *argv[])
{
    int fd;
    int ret;
    char *buff = NULL;
    char *read_buff = NULL;
    int i;
    uint8_t flag = 0;
    uint8_t usr_flag;
    int exit = 0;
    char *numb = NULL;
    char *rem = NULL;
    int star;
    int stop;
    int poin = 0;
    char *dat = NULL;
    int fc = 0;
    char *file = NULL;
    int exit_stat;
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

    while (exit < exit_stat)
    {

        scanf("%s", buff);
        strcat(buff, "\r");

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
                printf("rem[%d]: %c\n", i - 4, rem[i - 4]);
            }
        }

        if (!strcmp(numb, "quit"))
            break;

        if (!strcmp(numb, "OUTP") && poin > 0)
            flag = 2;

        if (!strcmp(numb, "OPC?") && strlen(rem) > 0)
            flag = 3;

        for (i = 0; i < num_com.num; i++)
        {
            if (strcmp(numb, num_com.check[i]) == 0)
            {
                flag = 4;
                usr_flag = i;
                break;
            }
        }

        switch (flag)
        {
        case 0:
            ret = write_port(fd, buff, strlen(buff));
            if (ret < 0)
                goto fail;
            break;
        case 1:
            poin = atoi(buff);
            dat = malloc(50 * poin);
            if (dat == NULL)
            {
                perror("memory error");
                goto fail;
            }
            else
            {
                memset(dat, 0, strlen(dat));
                printf("dat malloc success, poin: %d\n", poin);
            }
            flag = 0;
        case 2:
            ret = write_port(fd, buff, strlen(buff));
            if (ret < 0)
                goto fail;
            ret = read_port(fd, dat, 50 * poin);
            if (ret < 0)
                goto fail;
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
            fprintf(f,"\nSTAR%dSTOP%dPOIN%d", star, stop, poin);
            fclose(f);
            exit++;
            fc++;
            flag = 0;
            break;
        case 3:
            ret = write_port(fd, buff, strlen(buff));
            if (ret < 0)
                goto fail;
            ret = read_port(fd, read_buff, 1);
            if (ret < 0)
                goto fail;
            printf("Read success\n");
            flag = 0;
            break;
        case 4:
            ret = write_port(fd, buff, strlen(buff));
            if (ret < 0)
                goto fail;
            switch (usr_flag)
            {
            case 0:
                star = atoi(rem);
                flag = 0;
                break;
            case 1:
                stop = atoi(rem);
                flag = 0;
                break;
            case 2:
                flag = 1;
                break;
            }
            break;
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