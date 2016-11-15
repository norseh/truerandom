#!/bin/bash

TOTALTIME=""
echo "PIN,time(milissecond)" > log.txt

for (( i=1; i<=$1; i++ )); do
  VAR1=$(date +%s%N);
  PIN=$(./truerandom.sh);
  VAR2=$(date +%s%N);
  TIME=$(($VAR2-$VAR1));
  TOTALTIME=$(($TOTALTIME+$TIME));
  TIME=$(($TIME/1000000))
  echo "$PIN,$TIME" | tee log.txt;
done

AVERAGETIME=$(($TOTALTIME/$1));
echo "Requests: $1 - Total Time: $(($TOTALTIME/1000000000))s - Average Time (per Token): $(($AVERAGETIME/1000000))ms/token"
