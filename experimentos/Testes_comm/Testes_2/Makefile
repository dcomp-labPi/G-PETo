MCC = mpic++
CC = nvcc
CFLAGS = -I/usr/local/cuda-8.0/include -L/usr/local/cuda-8.0/lib64/ -lcudart
LIBS = -arch=sm_30
OBJS = func.o direct.o
TARGET = direct


all: $(TARGET)

direct: $(OBJS)
	$(MCC) $(OBJS) $(CFLAGS) -o direct

direct.o: direct.cpp func.cu func.h
	$(MCC) $(CFLAGS) -c direct.cpp
	
func.o: func.cu func.h
	$(CC) $(CFLAGS) $(LIBS) -c func.cu -o func.o
	
clean:
	rm -rf *.o $(TARGET)

run:
	mpirun -np 2 $(TARGET)
