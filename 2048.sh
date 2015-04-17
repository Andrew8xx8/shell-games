#!/bin/bash
stty -echo

# Init output
OLD_IFS="$IFS"
IFS=

tput clear

tput civis

# ___   ___         ___
#    | |  /| | |   |   |
# -+-  | + |  -+-   -+-
#|     |/  |   |   |   |
# ---   ---         ---

function drawChar {
  $1
}

declare -a board

while :
do
  read -s -n 1 key
  case "$key" in
    h)
	;;
    j)
	;;
    k)
	;;
    l)
	;;
    q)
      exitGame
	;;
  esac
done

tput cnorm
IFS="$OLD_IFS"
