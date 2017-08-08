all: 
	/usr/local/cuda-8.0/bin/nvcc -I/opt/openmpi-2.1.1/ompi/include -lmpi  /home/labpi/Dropbox/renan/wscad2017/renan/intranode/cuda-aware-mpi/main.cu -lpng16 -m64 -arch=sm_20 -o /home/labpi/Dropbox/renan/wscad2017/renan/intranode/cuda-aware-mpi/main
run: 
	mpirun -n 2 /home/labpi/Dropbox/renan/wscad2017/renan/intranode/cuda-aware-mpi/main
