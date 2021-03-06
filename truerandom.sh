#!/bin/bash
#
# echo "Usage :$0 TokenLength"
# echo "example 1: $0 - for a PIN of 6 digits (default)"
# echo "example 3: $0 4 - for a PIN of 4 digits"

DEFAULTLENGTH=6
HASH=sha512sum
#Generating a random not only time based
#Difficulting the attacker's life
RANDOMIZER=$(echo $RANDOM)
RANDOMIZER=$RANDOMIZER$(cat /proc/uptime)
RANDOMIZER=$RANDOMIZER$(cat /proc/loadavg)
#RANDOMIZER=$RANDOMIZER$(tcpdump -nnnnAs0 -i any -c 1 2>/dev/null) #not recommendeb because time to wait
RANDOMIZER=$RANDOMIZER$(cat /proc/softirqs)
RANDOMIZER=$RANDOMIZER$(od -va -N80 -tu4 < /dev/random)

#Verifying if the length of token was setted. If not 6 digits are default
[[ -z $1 ]] && LENGTH=$DEFAULTLENGTH || LENGTH=$1

#Verifying debug mode
[[ -z $2 ]] && DEBUG="ON" || DEBUG="OFF"

ARRAYLENGTH=$(($LENGTH * $LENGTH))

#Getting initial random number (predictable with some hard work and with access in the randomizer machine)
VAR=$(echo $RANDOMIZER | $HASH | tr -dc '0-9')

#Validating if the token length requested is bigger that
#the number of numeric digits from hash
#if it is insufficient we made a new hash and concatenate the numbers with the existent array
if [ ${#VAR} -lt $ARRAYLENGTH ]; then
  h=1
  while [ ${#VAR} -lt $ARRAYLENGTH ]; do
    VAR=$VAR$(echo $VAR | $HASH | tr -dc '0-9')
    h=$(($h+1))
  done
fi

if [ $DEBUG -eq "ON" ]; then
  #Debug mode
  echo $ARRAYLENGTH
  echo "Randomizer: $RANDOMIZER"
  echo "Initial length: ${#VAR}"
  echo "Initial chars: $VAR"
fi

#Declaring the variable TRUERANDOM to get length 0 (zero)
TRUERANDOM=""

i=$(shuf -i 1-${#VAR} -n 1)
if [ $DEBUG -eq "ON" ]; then echo "We are starting from $i th char to compose the token";fi
while [ ${#TRUERANDOM} -lt $LENGTH ]; do
##Sorting the chars to choose (second random and not so easy to guess)
  BIN=$(shuf -i 0-1 -n 1)
  if [ $BIN -eq 1 ]; then
    TRUERANDOM=$TRUERANDOM${VAR:$i:1}
    if [ $DEBUG -eq "ON" ]; then echo "Choosen char: $i to compose the token";fi
  fi
##If we see all chars and unfortunately the token
##does not reach the desired length we start again
##from first char to give a second chance to them :)
  if [ $i -lt ${#VAR} ]; then
####Adding the third layer of random (jumping from chars of array :)
    JUMP=$(shuf -i 1-$LENGTH -n 1)
    i=$(($i+$JUMP));
    if [ $i -ge ${#VAR} ]; then
      i=$(shuf -i 0-$LENGTH -n 1);
######VAR=$(echo $VAR | rev) - if you want to reverse order of array
######not recommended because if you revert the same index have more probability to be choosen
      if [ $DEBUG -eq "ON" ]; then echo "Restarting the search on array...";fi
    fi
    if [ $DEBUG -eq "ON" ]; then echo "Jumping to $i th char";fi
  else
    i=$(shuf -i 0-$LENGTH -n 1)
    if [ $DEBUG -eq "ON" ]; then echo "Restarting the search on array...";fi
  fi
done

echo $TRUERANDOM
