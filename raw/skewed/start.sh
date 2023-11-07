MAIN_PATH="/root/AE_CSAL/"

# precondition again
fio $MAIN_PATH/precondition/rnd.job

echo "start zipf 0.8 4k" > $MAIN_PATH/raw/skewed/status
fio $MAIN_PATH/raw/skewed/fio_4k_zipf0.8.job > $MAIN_PATH/raw/skewed/results/4k_zipf0.8.result
echo "zipf 0.8 4k DONE" >> $MAIN_PATH/raw/skewed/status

echo "start zipf 1.2 4k" >> $MAIN_PATH/raw/skewed/status
fio $MAIN_PATH/raw/skewed/fio_4k_zipf1.2.job > $MAIN_PATH/raw/skewed/results/4k_zipf1.2.result
echo "zipf 1.2 4k DONE" >> $MAIN_PATH/raw/skewed/status

echo "start zipf 0.8 64k" >> $MAIN_PATH/raw/skewed/status
fio $MAIN_PATH/raw/skewed/fio_64k_zipf0.8.job > $MAIN_PATH/raw/skewed/results/64k_zipf0.8.result
echo "zipf 0.8 64k DONE" >> $MAIN_PATH/raw/skewed/status

echo "start zipf 1.2 64k" >> $MAIN_PATH/raw/skewed/status
fio $MAIN_PATH/raw/skewed/fio_64k_zipf1.2.job > $MAIN_PATH/raw/skewed/results/64k_zipf1.2.result
echo "zipf 1.2 64k DONE" >> $MAIN_PATH/raw/skewed/status