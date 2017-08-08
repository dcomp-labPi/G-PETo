for i in 13107200 26214400 39321600 52428800 65536000 78643200; do
        echo "Tamanho ${i} ints" >> tempos_MPI_intra.txt
        echo ${i} > tamanho_vetor
        for j in `seq 1 30`;do
                start=`date +%s%N | cut -b1-13`
                sh execute.sh
                end=`date +%s%N | cut -b1-13`
                runtime=$((end-start))
                echo $runtime >> tempos_MPI_intra.txt
        done;

done;
