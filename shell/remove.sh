#! /bin/bash

PID=`ps -ef | grep node | grep shell_build | awk '{print $2}'`
CURR_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

if [[ "" !=  "$PID"  ]]; then
Kill -9 PID
fi;

rm -rf $CURR_DIR

crontab -l | grep -v 'shell' | crontab -