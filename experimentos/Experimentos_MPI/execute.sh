#teste
#echo "Executando framework distribuido"

mpirun --map-by slot -hostfile comm/hosts.cfg ./comm/framework
