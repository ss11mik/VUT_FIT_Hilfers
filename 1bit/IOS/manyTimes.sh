#!/bin/bash

trap "wasInt=1" INT
wasInt=0

i=0
errRuns=0

mkdir err 2>/dev/null
killall proj2 2>/dev/null

chmod +x doe
chmod +x skriptos.sh

for x in {1..999999}
do
    ./skriptos.sh
    ret="$?"
    if [ "$ret" -ne "0" ]; then
        cp proj2.out "err/err$x.out"
        echo -en "\007" #beep
        ((errRuns++))
        if [ "$errRuns" -eq 10 ]; then
            echo "Run failed too many times in row. Exiting"
            exit 1
        fi
    else
        errRuns=0
    fi
    
    if [ "$wasInt" -eq 1 ]; then
		 exit 0
    fi
    ((i++))
    echo "$(date "+%H:%M:%S"): Ran $i times"
done
