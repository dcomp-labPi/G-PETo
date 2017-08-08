CUFILES=  arquivo1.cu arquivo2.cu
OBJS= arquivo1.o arquivo2.o 
TARGET= arquivo1.o arquivo2.o  link.o libfw.so



all: $(TARGET)



libfw.so: link.o 
	g++  -shared -Wl,-soname,libfw.so -o libfw.so arquivo1.o arquivo2.o  comm/comm.o link.o -L/usr/local/cuda-8.0/lib64  -lcudart 


link.o:  arquivo1.cu arquivo2.cu
	nvcc  -m64   -arch=sm_20 -dlink -Xcompiler  -fPIC  comm/comm.o arquivo1.o arquivo2.o  -o link.o


arquivo1.o: arquivo1.cu arquivo1.h comm/comm.h
	nvcc -m64 -arch=sm_20 -dc  -Xcompiler -fPIC -c arquivo1.cu 


arquivo2.o: arquivo2.cu arquivo2.h comm/comm.h
	nvcc -m64 -arch=sm_20 -dc  -Xcompiler -fPIC -c arquivo2.cu 


clean: 
	rm -f link.o libfw.so arquivo1.o arquivo2.o  
