TARGET= funcs_link.o comm.o framework.o framework
CCMPI = mpic++

all: $(TARGET)


framework: framework.o comm.o funcs_link.o
	$(CCMPI) -o framework  -Wl,--no-as-needed -fpic -I/usr/local/cuda-8.0/include -L/usr/local/cuda-8.0/lib64 -lcudart -lcudadevrt -ldl framework.o comm.o funcs_link.o

framework.o: framework.cpp comm.cpp comm.h funcs.cu funcs.h
	$(CCMPI)  -c framework.cpp -Wl,--no-as-needed -ldl 

funcs_link.o: funcs.cu funcs.h
	#nvcc -Xcompiler '-fPIC' -rdc=false -c funcs.cu
	#nvcc -Xcompiler '-fPIC' -dlink funcs.o -o funcs_link.o 
	nvcc -m64 -arch=sm_20 -Xcompiler -fPIC -c funcs.cu -o funcs_link.o

comm.o: comm.cpp comm.h funcs.cu funcs.h
	$(CCMPI)  -fPIC -c comm.cpp

clean:
	rm -rf framework comm.o framework.o funcs_link.o

