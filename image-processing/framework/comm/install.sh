echo "Installing Framework"

/opt/openmpi/bin/mpic++ -c comm.cpp comm.h -Wl,--no-as-needed -ldl
/opt/openmpi/bin/mpic++ -o framework  -Wl,--no-as-needed -fpic -I/usr/local/cuda-7.5/include -L/usr/local/cuda-7.5/lib64 -lcudart -ldl comm.o
