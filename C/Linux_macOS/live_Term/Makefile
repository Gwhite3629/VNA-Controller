TARGET=live
OBJS=live.o serial.o GPIB_prof.o
CFLAGS=-Wall

all: ${TARGET}

${TARGET}: ${OBJS}
	${CC} -o ${TARGET} ${OBJS}

clean:
	rm -f ${TARGET} ${OBJS} core*
	rm -f data