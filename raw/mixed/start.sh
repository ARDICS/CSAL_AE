MAIN_PATH="/root/AE_CSAL/"

fio $MAIN_PATH/precondition/rnd.job

echo "start mixed 4k" > $MAIN_PATH/raw/mixed/status
fio $MAIN_PATH/raw/mixed/fio_rwmix_4k.job > $MAIN_PATH/raw/mixed/results/rwmix_4k.result
echo "mixed 4k DONE" >> $MAIN_PATH/raw/mixed/status

echo "start mixed 64k" >> $MAIN_PATH/raw/mixed/status
fio $MAIN_PATH/raw/mixed/fio_rwmix_64k.job > $MAIN_PATH/raw/mixed/results/rwmix_64k.result
echo "mixed 64k DONE" >> $MAIN_PATH/raw/mixed/status