#!/bin/bash
stty -echo

# Init output
OLD_IFS="$IFS"
IFS=

tput clear

tput civis

# Calculate size

SCREEN_WIDTH=$(tput cols)
SCREEN_HEIGHT=$(($(tput lines) - 1))
WIDTH=$((60 % (SCREEN_WIDTH - 2)))
HEIGHT=$((20 % (SCREEN_HEIGHT - 2)))
LEFT=$(((SCREEN_WIDTH - WIDTH) / 2))
TOP=$(((SCREEN_HEIGHT - HEIGHT) / 2))

# Declare world
declare -a prevWorld
declare -a world

function draw {
  for (( row = 0; row < HEIGHT; row++ ))
  do
    buf=""
    tput cup $(($TOP + $row)) $LEFT

    for (( column = 0; column < WIDTH; column++ ))
    do
      key=1$row\0$column
      if [ ${world[$key]} == 1 ]
      then
        buf+="+"
      else
        buf+=" "
      fi
    done

    echo $buf
  done
}

function step {
  for (( row = 0; row < HEIGHT; row++ ))
  do
    for (( column = 0; column < WIDTH; column++ ))
    do
      key=1$row\0$column

      x1=$(($row - 1))
      if [ $x1 -lt 0 ]; then x1=$(($HEIGHT-1)); fi
      x2=$row
      x3=$((($row + 1) % $HEIGHT))

      y1=$(($column - 1))
      if [ $y1 -lt 0 ]; then y1=$(($WIDTH-1)); fi
      y2=$column
      y3=$((($column + 1) % $WIDTH))

      alive=$((
        ${prevWorld[1$x1\0$y1]} +
        ${prevWorld[1$x2\0$y1]} +
        ${prevWorld[1$x3\0$y1]} +
        ${prevWorld[1$x1\0$y2]} +
        ${prevWorld[1$x3\0$y2]} +
        ${prevWorld[1$x1\0$y3]} +
        ${prevWorld[1$x2\0$y3]} +
        ${prevWorld[1$x3\0$y3]}
      ))

      if [ ${prevWorld[$key]} == 0 ]
      then
        if [ $alive -eq 3 ]
        then
          world[$key]=1
        fi
      else
        if [ \( $alive -lt 2 \) -o \( $alive -gt 3 \) ]
        then
          world[$key]=0
        fi
      fi
    done
  done
}

tput cup $(($TOP - 5)) $(($SCREEN_WIDTH / 2 - 16))
echo " ______  _______ _______ _______ "
tput cup $(($TOP - 4)) $(($SCREEN_WIDTH / 2 - 16))
echo "|     |_|_     _|    ___|    ___|"
tput cup $(($TOP - 3)) $(($SCREEN_WIDTH / 2 - 16))
echo "|       |_|   |_|    ___|    ___|"
tput cup $(($TOP - 2)) $(($SCREEN_WIDTH / 2 - 16))
echo "|_______|_______|___|   |_______|"
line=""
for (( column = 0; column <= WIDTH; column++ ))
do
  line+="_"
done
tput cup $(($TOP - 1)) $(($LEFT))
echo $line
tput cup $(($TOP + $HEIGHT)) $(($LEFT))
echo $line

for (( row = 0; row <= HEIGHT; row++ ))
do
tput cup $(($TOP + $row)) $(($LEFT - 1))
echo "|"
tput cup $(($TOP + $row)) $(($LEFT + $WIDTH + 1))
echo "|"
done

# Init by random
for (( row = 0; row < HEIGHT; row++ ))
do
  for (( column = 0; column < WIDTH; column++ ))
  do
    key=1$row\0$column
    world[$key]=$(($RANDOM % 2))
  done
done

while [ 1==1 ]
do
  for (( row = 0; row < HEIGHT; row++ ))
  do
    for (( column = 0; column < WIDTH; column++ ))
    do
      key=1$row\0$column
      prevWorld[$key]=${world[$key]}
    done
  done

  step
  draw
done

tput cnorm
IFS="$OLD_IFS"
