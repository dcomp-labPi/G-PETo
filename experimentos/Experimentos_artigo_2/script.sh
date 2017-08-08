echo "Execuando experimentos"

for i in 1048576 2097152 4194304 6291456 8388608 10485760;
do

        echo $i > tamanho_matriz
        echo "Execucoes para ${i}" >> tempos_framework_2.txt
        for j in `seq 1 30`;do
                start=`date +%s%N | cut -b1-13`
                sh execute.sh
                end=`date +%s%N | cut -b1-13`
                runtime=$((end-start))
                echo $runtime >> tempos_framework_2.txt
        done;

done;

