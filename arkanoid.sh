#!/bin/bash
stty -echo

# Init output
OLD_IFS="$IFS"
IFS=

DELAY=0.2

tput civis
clear

SCREEN_WIDTH=$(tput cols)
SCREEN_HEIGHT=$(($(tput lines) - 1))
WIDTH=$((40 % (SCREEN_WIDTH - 2)))
HEIGHT=$((14 % (SCREEN_HEIGHT - 2)))

HALF_WIDTH=$((WIDTH/2))
HALF_HEIGHT=$((HEIGHT/2))

TOP=$(((SCREEN_HEIGHT - HEIGHT) / 2))
LEFT=$(((SCREEN_WIDTH - WIDTH) / 2))
BOTTOM=$((TOP + HEIGHT))
RIGHT=$((LEFT + WIDTH))

STATE='stop'

plateX=$((LEFT + HALF_WIDTH))
plateW=5
plateS=""

ballY=$((BOTTOM - 1))
ballX=$((LEFT + HALF_WIDTH + plateW / 2))
ballDY=-1
ballDX=-1
ballColors=(52 88 124 160 196)
currentColor=0
ballChar="+"
state="stop"
lifes=3

bricks=()

function putBrik {
  index=1$1\0$2
  briks[$index]=1
  tput cup $1 $2
  echo '='
}

function drawBricks {
  for (( row = $((TOP + 2)); row <= $((TOP + 7)); row++ ))
  do
    for (( column = $((LEFT + 3)); column <= $((RIGHT - 3)); column++ ))
    do
      if [ $(($column % 3)) == 0 ]
      then
        tput setaf 83
        putBrik $row $column
      fi
    done
  done

  for (( column = $((LEFT + 3)); column <= $((RIGHT - 3)); column++ ))
  do
    if [ $(($column % 2)) == 0 ]
    then
      tput setaf 84
      putBrik $((TOP + 3)) $column
    fi
    if [ $(($column % 3)) == 0 ]
    then
      tput setaf 85
      putBrik $((TOP + 6)) $column
    fi
  done

  for (( column = $((LEFT + 2)); column <= $((RIGHT - 2)); column++ ))
  do
    if [ $(($column % 4)) == 0 ]
    then
      tput setaf 86
      putBrik $((TOP + 8)) $column
    fi
    if [ $(($column % 2)) == 0 ]
    then
      tput setaf 86
      tput setaf 87
      putBrik $((TOP + 4)) $column
    fi
  done
}

function drawBorder {
  tput setaf 244
  tput cup $((TOP - 5)) $((LEFT + 5))
  echo "         _               _   _ "
  tput cup $((TOP - 4)) $((LEFT + 5))
  echo " ___ ___| |_ ___ ___ ___|_|_| |"
  tput cup $((TOP - 3)) $((LEFT + 5))
  echo "| .'|  _| '_| .'|   | . | | . |"
  tput cup $((TOP - 2)) $((LEFT + 5))
  echo "|__,|_| |_,_|__,|_|_|___|_|___|"

  line=""
  tput setaf 241
  for (( column = 0; column <= WIDTH; column++ ))
  do
    line+="_"
  done
  tput cup $((TOP - 1)) $LEFT
  echo $line
  tput cup $BOTTOM $LEFT
  echo $line

  for (( row = 0; row <= HEIGHT; row++ ))
  do
    tput cup $((TOP + row)) $((LEFT - 1))
    echo "|"
    tput cup $((TOP + row)) $((RIGHT + 1))
    echo "|"
  done

  tput cup $((BOTTOM + 2)) $LEFT
  echo "Press 'h' or 'l' to start playing"
}

function clearBall {
  tput cup $ballY $ballX
  echo " "
}

function drawBall {
  tput setaf ${ballColors[$currentColor]}
  tput cup $ballY $ballX
  echo $ballChar

  currentColor=$(($currentColor + 1))
  if [ $currentColor -gt 4 ]
  then
    currentColor=0
  fi
}

function resetBall {
  clearBall
  ballY=$((BOTTOM - 1))
  ballX=$((plateX + plateW / 2))
  ballDY=-1
  ballDY=-1
  drawPlate
  drawBall
}

function move {
  (sleep $DELAY && kill -ALRM $$) &

  if [ $state != 'playing' ]
  then
    return
  fi

  clearBall
  ballY=$((ballY + ballDY))
  ballX=$((ballX + ballDX))

  if [ $ballX -gt $RIGHT ] || [ $ballX -lt $LEFT ]
  then
    ballDX=$((-ballDX))
    ballX=$((ballX + ballDX + ballDX))
  fi

  if [ $ballY -lt $TOP ]
  then
    ballDY=$((-ballDY))
    ballY=$((ballY + ballDY + ballDY))
  fi

  if [ $ballY -gt $((BOTTOM - 1)) ]
  then
    if [ $ballX -le $((plateX + plateW)) ] && [ $ballX -ge $plateX ]
    then
      ballX=$((plateX + plateW / 2))
      ballDY=$((-ballDY))
      ballY=$((ballY + ballDY + ballDY))
      drawPlate
    else
      resetBall
      drawBorder
      state='stop'
      lifes=$((lifes - 1))
    fi
  fi

  index=1$ballY\0$ballX
  if [ ${briks[$index]} ] && [ ${briks[$index]} == 1 ]
  then
    tput cup $ballY $ballX
    drawBall
    clearBall
    ballDY=$((-ballDY))
    ballY=$((ballY))
    briks[$index]=0
  fi

  drawBall
  tput setaf 7
  tput cup $((BOTTOM + 2)) $LEFT
  if [ $lifes -gt 0 ]
  then
    echo "Lifes: " $lifes "                       "
  else
    echo "Game over =(((                           "
    exitGame
  fi
}

function calcPlateS {
  plateS=" +"
  for (( i = 0; i < $((plateW - 1)); i++ ))
  do
    plateS+="-"
  done
  plateS+="+ "
}

function drawPlate {
  tput setaf 2
  tput cup $((BOTTOM - 1)) $((plateX - 1))
  echo $plateS
  if [ $plateX == $LEFT ]
  then
    tput setaf 241
    tput cup $((BOTTOM - 1)) $((plateX - 1))
    echo "|"
  fi
}

function exitGame {
  echo "Goodbye!"
  trap exit ALRM
  tput cnorm
  IFS="$OLD_IFS"
  exit 0
}

function startGame {
  if [ $lifes -ge 0 ]
  then
    state='playing'
  else
    state='gameOver'
  fi
}

trap move ALRM

calcPlateS
drawBricks
drawBorder
drawBall
drawPlate
resetBall
move

while :
do
  read -rsn3 -d '' -n 1 key
  case "$key" in
    h)
      if [ $state == 'stop' ]
      then
        ballDX=-1
        startGame
      else
        if [ $plateX -gt $LEFT ]
        then
          plateX=$((plateX - 1))
          drawPlate
          drawBall
        fi
      fi
	;;
    l)
      if [ $state == 'stop' ]
      then
        ballDX=1
        startGame
      else
        if [ $plateX -lt $((RIGHT - $plateW)) ]
        then
          plateX=$((plateX + 1))
          drawPlate
          drawBall
        fi
      fi
	;;
    q)
      exitGame
	;;
  esac
done

