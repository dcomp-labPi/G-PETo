CUFILES=  funcao.cu
OBJS= funcoes.o funcao.o 
TARGET= $(OBJS) link.o libfw.so
CUDACC= /usr/local/cuda-8.0/bin/nvcc

all: framework file

framework:
	$(MAKE) -C ./comm/

file: $(TARGET)


libfw.so: link.o 
	g++  -shared -Wl,-soname,libfw.so -o libfw.so $(OBJS) comm/comm.o link.o -L/usr/local/cuda-8.0/lib64  -lcudart -lpng


link.o:  funcao.cu
	$(CUDACC)  -m64   -arch=sm_20 -lpng16 -dlink -Xcompiler  -fPIC  comm/comm.o $(OBJS) -o link.o

funcoes.o: funcoes.h funcoes.cu
	$(CUDACC) -m64 -arch=sm_20 -dc  -Xcompiler -fPIC -c funcoes.cu


funcao.o: funcao.cu funcao.h comm/comm.h
	$(CUDACC) -m64 -arch=sm_20 -dc  -Xcompiler -fPIC -c funcao.cu 


clean: 
	rm -f link.o libfw.so funcao.o  
	$(MAKE) -C ./comm/ clean
