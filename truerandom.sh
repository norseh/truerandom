#!/bin/bash
#
# echo "Usage :$0 TokenLength"
# echo "example 1: $0 - for a PIN of 6 digits (default)"
# echo "example 3: $0 4 - for a PIN of 4 digits"

DEFAULTLENGTH=6
HASH="shasum -a 512"
#Generating a random not only time based
#Difficulting the attacker's life
RANDOMIZER=$(echo $RANDOM)
RANDOMIZER=$RANDOMIZER$(sysctl -n kern.boottime)
RANDOMIZER=$RANDOMIZER$(sysctl -n vm.loadavg)
#RANDOMIZER=$RANDOMIZER$(tcpdump -nnnnAs0 -i any -c 1 2>/dev/null)
RANDOMIZER=$RANDOMIZER$(sysctl -n machdep)
RANDOMIZER=$RANDOMIZER$(od -va -N80 -tu4 < /dev/random)

#Verifying if the length of token was setted. If not 6 digits are default
[[ -z $1 ]] && LENGTH=$DEFAULTLENGTH || LENGTH=$1

#Verifying debug mode
[[ -z $2 ]] && DEBUG="ON" || DEBUG="OFF"

ARRAYLENGTH=$(($LENGTH * $LENGTH))
#echo $ARRAYLENGTH

#Getting initial random number (predictable with some hard work and with access in the randomizer machine)
VAR=$(echo $RANDOMIZER | $HASH | tr -dc '0-9')

#Validating if the token length requested is bigger that
#the number of numeric digits from hash
if [ ${#VAR} -lt $ARRAYLENGTH ]; then
##echo $(($LENGTH * 2)) - we fucked the code here
  h=1
  while [ ${#VAR} -lt $ARRAYLENGTH ]; do
    VAR=$VAR$(echo $VAR | $HASH | tr -dc '0-9')
    h=$(($h+1))
  done
fi

#Debug mode :)
#echo "Randomizer: $RANDOMIZER"
#echo "Var com ${#VAR} caracteres: $VAR"

#Declaring the variable TRUERANDOM to get length 0 (zero)
TRUERANDOM=""

i=$(gshuf -i 1-"${#VAR}" -n "1")
while [ "${#TRUERANDOM}" -lt "$LENGTH" ]; do
##Sorting the chars to choose (second random and not so easy to guess)
  BIN=$(gshuf -i 0-1 -n 1)
  if [ "$BIN" -eq "1" ]; then
    TRUERANDOM="$TRUERANDOM${VAR:$i:1}"
    #echo "escolhido caracter $i"
  fi
##If we see all chars and unfortunately the token
##does not reach the desired length we start again
##from first char to give a second chance to them :)
  if [ "$i" -lt "${#VAR}" ]; then
####Adding the third layer of random (jumping from chars of array :)
    JUMP=$(gshuf -i 1-"$LENGTH" -n 1)
    i=$(echo "$i+$JUMP" | bc);
    if [ "$i" -ge "${#VAR}" ]; then
      i=$(gshuf -i 0-"$LENGTH" -n 1);
######VAR=$(echo $VAR | rev) - if you want to reverse order of array
######not recommended because if you revert the same index have more probability to be choosen
      #echo "reiniciando varredura no vetor devido JUMP...";
######echo "$VAR"
    fi
#    echo "salto: $i";
  else
    i=$(gshuf -i 0-"$LENGTH" -n 1)
#    echo "reiniciando varredura no vetor..."
  fi
done

echo "$TRUERANDOM"
