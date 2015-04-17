#!/bin/sh

function _each() {
  for i in "${array[@]}"
  do
    $2 "$i"
  done
}

function _map() {
  count=${#array[@]}
  i=0

  while [ "$i" -lt "$count" ]
  do
    array[$i]=$($2 "${array[$i]}")
    let "i = $i + 1"
  done
}


