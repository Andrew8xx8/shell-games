#!/bin/bash
MAX=1000

function stringKey1 {
  local array=()

  for (( i = 0; i < MAX; i++ ))
  do
    for (( k = 0; k < MAX; k++ ))
    do
      index=1$i0$k
      array[$index]=$RANDOM
    done
  done
}


function integerKey {
  local array=()

  for (( i = 1; i < MAX; i++ ))
  do
    for (( k = 1; k < MAX; k++ ))
    do
      index=$(($i * $MAX + $k))
      array[$index]=$RANDOM
    done
  done
}

function integerLetKey {
  local array=()

  for (( i = 1; i < MAX; i++ ))
  do
    for (( k = 1; k < MAX; k++ ))
    do
      let "index = $i * $MAX + $k"
      array[$index]=$RANDOM
    done
  done
}

echo "\$I = \$((\$X * \$ROW + \$Y))"
time integerKey
echo "let \"I = \$X * \$ROW + \$Y\""
time integerLetKey
echo "\$I = 1\$X0\$Y"
time stringKey1
