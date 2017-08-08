echo "Executando para PACOTE DE 1GB"
for i in 262144000; do
        echo "MPI PADRAO" >> tempos_MPI_pacotes_1000.txt
        echo "MPI PADRAO"
        for j in `seq 1 30`;do
                start=`date +%s%N | cut -b1-13`
                /opt/openmpi/bin/mpirun -npernode 1 -hostfile hosts.cfg  ./direct 0 $i
                end=`date +%s%N | cut -b1-13`
                runtime=$((end-start))
                echo $runtime >> tempos_MPI_pacotes_1000.txt
        done;

done;

for i in 262144000; do
        echo "MPI P2P" >> tempos_MPI_pacotes_1000.txt
        echo "MPI P2P"
        for j in `seq 1 30`;do
                start=`date +%s%N | cut -b1-13`
                /opt/openmpi/bin/mpirun -npernode 1 -hostfile hosts.cfg  ./direct 1 $i
                end=`date +%s%N | cut -b1-13`
                runtime=$((end-start))
                echo $runtime >> tempos_MPI_pacotes_1000.txt
        done;

done;

for i in 262144000; do
        echo "INTRA PADRAO" >> tempos_MPI_pacotes_1000.txt
        echo "INTRA PADRAO"
        for j in `seq 1 30`;do
                start=`date +%s%N | cut -b1-13`
                /opt/openmpi/bin/mpirun -npernode 1 -hostfile hosts.cfg  ./direct 2 $i
                end=`date +%s%N | cut -b1-13`
                runtime=$((end-start))
                echo $runtime >> tempos_MPI_pacotes_1000.txt
        done;

done;

for i in 262144000; do
        echo "INTRA P2P" >> tempos_MPI_pacotes_1000.txt
        echo "INTRA P2P"
        for j in `seq 1 30`;do
                start=`date +%s%N | cut -b1-13`
                /opt/openmpi/bin/mpirun -npernode 1 -hostfile hosts.cfg  ./direct 3 $i
                end=`date +%s%N | cut -b1-13`
                runtime=$((end-start))
                echo $runtime >> tempos_MPI_pacotes_1000.txt
        done;

done;
