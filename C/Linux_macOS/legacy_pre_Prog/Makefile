TARGET=main
OBJS=main.o DATA_prof.o GPIB_prof.o MEAS_prof.o serial.o selector.o
CFLAGS=-Wall

all: ${TARGET}



${TARGET}: ${OBJS}
	${CC} -o ${TARGET} ${OBJS}

clean:
	rm -f ${TARGET1} ${OBJS1} core*
	rm -f data