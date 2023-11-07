MAIN_PATH="/root/AE_CSAL/"

# precondition again
fio $MAIN_PATH/precondition/seq.job
fio $MAIN_PATH/precondition/seq.job

# start
echo "start seq 4k" > $MAIN_PATH/raw/uniform/status
fio $MAIN_PATH/raw/uniform/fio_seq_4k.job > $MAIN_PATH/raw/uniform/results_seq_workloads/seq_4k.result
echo "seq 4k DONE" >> $MAIN_PATH/raw/uniform/status

echo "start seq 8k" >> $MAIN_PATH/raw/uniform/status
fio $MAIN_PATH/raw/uniform/fio_seq_8k.job > $MAIN_PATH/raw/uniform/results_seq_workloads/seq_8k.result
echo "seq 8k DONE" >> $MAIN_PATH/raw/uniform/status

echo "start seq 16k" >> $MAIN_PATH/raw/uniform/status
fio $MAIN_PATH/raw/uniform/fio_seq_16k.job > $MAIN_PATH/raw/uniform/results_seq_workloads/seq_16k.result
echo "seq 16k DONE" >> $MAIN_PATH/raw/uniform/status

echo "start seq 32k" >> $MAIN_PATH/raw/uniform/status
fio $MAIN_PATH/raw/uniform/fio_seq_32k.job > $MAIN_PATH/raw/uniform/results_seq_workloads/seq_32k.result
echo "seq 32k DONE" >> $MAIN_PATH/raw/uniform/status

echo "start seq 64k" >> $MAIN_PATH/raw/uniform/status
fio $MAIN_PATH/raw/uniform/fio_seq_64k.job > $MAIN_PATH/raw/uniform/results_seq_workloads/seq_64k.result
echo "seq 64k DONE" >> $MAIN_PATH/raw/uniform/status

echo "start seq 128k" >> $MAIN_PATH/raw/uniform/status
fio $MAIN_PATH/raw/uniform/fio_seq_128k.job > $MAIN_PATH/raw/uniform/results_seq_workloads/seq_128k.result
echo "seq 128k DONE" >> $MAIN_PATH/raw/uniform/status

# precondition again
fio $MAIN_PATH/precondition/rnd.job
fio $MAIN_PATH/precondition/rnd.job

echo "start rnd 4k" >> $MAIN_PATH/raw/uniform/status
fio $MAIN_PATH/raw/uniform/fio_rnd_4k.job > $MAIN_PATH/raw/uniform/results_rnd_workloads/rnd_4k.result
echo "rnd 4k DONE" >> $MAIN_PATH/raw/uniform/status

echo "start rnd 8k" >> $MAIN_PATH/raw/uniform/status
fio $MAIN_PATH/raw/uniform/fio_rnd_8k.job > $MAIN_PATH/raw/uniform/results_rnd_workloads/rnd_8k.result
echo "rnd 8k DONE" >> $MAIN_PATH/raw/uniform/status

echo "start rnd 16k" >> $MAIN_PATH/raw/uniform/status
fio $MAIN_PATH/raw/uniform/fio_rnd_16k.job > $MAIN_PATH/raw/uniform/results_rnd_workloads/rnd_16k.result
echo "rnd 16k DONE" >> $MAIN_PATH/raw/uniform/status

echo "start rnd 32k" >> $MAIN_PATH/raw/uniform/status
fio $MAIN_PATH/raw/uniform/fio_rnd_32k.job > $MAIN_PATH/raw/uniform/results_rnd_workloads/rnd_32k.result
echo "rnd 32k DONE" >> $MAIN_PATH/raw/uniform/status

echo "start rnd 64k" >> $MAIN_PATH/raw/uniform/status
fio $MAIN_PATH/raw/uniform/fio_rnd_64k.job > $MAIN_PATH/raw/uniform/results_rnd_workloads/rnd_64k.result
echo "rnd 64k DONE" >> $MAIN_PATH/raw/uniform/status

echo "start rnd 128k" >> $MAIN_PATH/raw/uniform/status
fio $MAIN_PATH/raw/uniform/fio_rnd_128k.job > $MAIN_PATH/raw/uniform/results_rnd_workloads/rnd_128k.result
echo "rnd 128k DONE" >> $MAIN_PATH/raw/uniform/status