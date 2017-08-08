OBJS= arquivo1.o arquivo2.o 
TARGET= comm.o framework.o framework
CCMPI = mpic++

all: $(TARGET)


framework: framework.o funcs.o comm.o
	$(CCMPI) -o framework  -Wl,--no-as-needed -fpic -I/usr/local/cuda-8.0/include -L/usr/local/cuda-8.0/lib64 -lcudart -ldl framework.o comm.o funcs.o

framework.o: framework.cpp funcs.cu funcs.h comm.cpp comm.h
	$(CCMPI)  -c framework.cpp -Wl,--no-as-needed -ldl

funcs.o: funcs.cu funcs.h
	nvcc -m64 -arch=sm_20 -c funcs.cu

comm.o: comm.cpp comm.h
	$(CCMPI)  -fPIC -c comm.cpp

clean:
	rm -rf framework comm.o framework.o funcs.o

