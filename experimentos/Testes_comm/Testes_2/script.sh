
echo "Executando experimentos de transferência de dados entre GPUS"

echo "Executando para MPI_PADRAO"
for i in 13107200 26214400 39321600 52428800 65536000 78643200; do
	echo "Tamanho ${i} ints" >> tempos_MPI_padrão.txt
	echo "Tamanho ${i} ints"
	for j in `seq 1 30`;do
		start=`date +%s%N | cut -b1-13`
		mpirun -npernode 1 -hostfile hosts.cfg  ./direct 0 $i
		end=`date +%s%N | cut -b1-13`
		runtime=$((end-start))
		echo $runtime >> tempos_MPI_padrão.txt
	done;

done;
echo "Executando para MPI_P2P"
for i in 13107200 26214400 39321600 52428800 65536000 78643200; do
        echo "Tamanho ${i} ints" >> tempos_MPI_P2P.txt
       echo "Tamanho ${i} ints"
        for j in `seq 1 30`;do
                start=`date +%s%N | cut -b1-13`
                mpirun -npernode 1 -hostfile hosts.cfg  ./direct 1 $i
                end=`date +%s%N | cut -b1-13`
                runtime=$((end-start))
                echo $runtime >> tempos_MPI_P2P.txt
        done;

done;
echo "Executando para INTRA_PADRAO"
for i in 13107200 26214400 39321600 52428800 65536000 78643200; do
        echo "Tamanho ${i} ints" >> tempos_intra_padrao.txt
        echo "Tamanho ${i} ints"
        for j in `seq 1 30`;do
                start=`date +%s%N | cut -b1-13`
                mpirun -npernode 1 -hostfile hosts.cfg  ./direct 2 $i
                end=`date +%s%N | cut -b1-13`
                runtime=$((end-start))
                echo $runtime >> tempos_intra_padrao.txt
        done;

done;

echo "Executando para INTRA_P2P"
for i in 13107200 26214400 39321600 52428800 65536000 78643200; do
        echo "Tamanho ${i} ints" >> tempos_intra_P2P.txt
        echo "Tamanho ${i} ints"
        for j in `seq 1 30`;do
                start=`date +%s%N | cut -b1-13`
                mpirun -npernode 1 -hostfile hosts.cfg  ./direct 3 $i
                end=`date +%s%N | cut -b1-13`
                runtime=$((end-start))
                echo $runtime >> tempos_intra_P2P.txt
        done;

done;
