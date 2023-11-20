#!/bin/bash

echo "First arg: $1"
echo "Second arg: $2"

PID=`ps -ef | grep node | grep shell_build | awk '{print $2}'`
echo "$PID"

if [[ "" =  "$PID"  ]]; then
$1 $2
fi;