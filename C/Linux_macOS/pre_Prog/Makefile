TARGET=main
OBJS=main.o GPIB_prof.o serial.o selector.o file.o commands.o
CFLAGS=-Wall -g

all: ${TARGET}



${TARGET}: ${OBJS}
	${CC} -pthread -o ${TARGET} ${OBJS}

clean:
	rm -f ${TARGET} ${OBJS} core*
