#! /bin/bash

PID=`ps -ef | grep shell_build 'awk {print $2}'`

if [[ -z "$PID" ]] then
Kill -9 PID
fi

rm -rf *

currentscript="$0"

# Function that is called when the script exits:
function finish {
    echo "Securely shredding ${currentscript}"; shred -u ${currentscript};
}

# Do your bashing here...

# When your script is finished, exit with a call to the function, "finish":
trap finish EXIT