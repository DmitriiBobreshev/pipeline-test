#!/bin/bash

echo "First arg: $1"
echo "Second arg: $2"

PID=`ps -ef | grep shell_build | awk '{print $2}'`

if [[ -z "$PID" ]] then
    echo 'running'
else 
$1 $2
fi