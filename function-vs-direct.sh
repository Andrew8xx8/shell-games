#!/bin/bash
MAX=3000

function calcIndex {
  echo $(($1 * $1))
}

function callFunction {
  for (( i = 0; i < MAX; i++ ))
  do
    array[$i]=$(calcIndex $i)
  done
}


function calcDirect {
  for (( i = 1; i < MAX; i++ ))
  do
    array[$i]=$(($i * $i))
  done
}

function calcIndex1 {
  return $(($1 * $1))
}

function callFunction1 {
  for (( i = 0; i < MAX; i++ ))
  do
    calcIndex1 $i
    array[$i]=$?
  done
}

echo "Return by echo"
time callFunction

echo "Return by $? function"
time callFunction1

echo "Calc direct"
time calcDirect
