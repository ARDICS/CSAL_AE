MAIN_PATH="/root/AE_CSAL/"

echo "start round one" > $MAIN_PATH/precondition/status
fio $MAIN_PATH/precondition/seq.job
echo "round one DONE" >> $MAIN_PATH/precondition/status

echo "start round two" >> $MAIN_PATH/precondition/status
fio $MAIN_PATH/precondition/seq.job
echo "round two DONE" >> $MAIN_PATH/precondition/status

echo "start round three" >> $MAIN_PATH/precondition/status
fio $MAIN_PATH/precondition/rnd.job
echo "round three DONE" >> $MAIN_PATH/precondition/status

echo "DONE" >> $MAIN_PATH/precondition/status