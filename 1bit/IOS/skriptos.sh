#!/bin/bash

# skriptos.sh
# Upravil 06/05/20 Ondřej Mikula
# převzato od louda (https://www.dropbox.com/s/c1j9s3z2wn1nwz3/skriptos?dl=0)

trap "echo Will exit after this proj2 finishes. ; wasInt=1" INT
wasInt=0

immigrants=(1 5 15)
wait=(0 420 2000)

for a in "${immigrants[@]}"
do
	for b in "${wait[@]}"
	do
		for c in "${wait[@]}"
		do
			for d in "${wait[@]}"
			do
				for e in "${wait[@]}"
				do
					if timeout 300 ./proj2 $a $b $c $d $e; then
						if ps aux | grep -E "\./proj2( +[0-9]+){5}" > /dev/null ;then
							echo "Nejsou ukonceny vsechny child procesy, argumenty $a $b $c $d $e"
							exit 1
						fi						
						if cat proj2.out | ./doe | grep -Eq "Alles gute";then
							:
						else
							echo "Failed with arguments $a $b $c $d $e"
							exit 1
						fi
						
                        mem=$(ipcs -tm | grep "$(whoami)" | wc -l)
                        if [ "$mem" -ne 0 ]; then
                            ipcs -tm | grep "$(whoami)" | awk '{print $1};' | xargs -L1 ipcrm -m
                            echo "The program didn't clear shared memory"
                            exit 2
                        fi

                        sem=$(ipcs -ts | grep "$(whoami)" | wc -l)
                        if [ "$sem" -ne 0 ]; then
                            ipcs -ts | grep "$(whoami)" | awk '{print $1};' | xargs -L1 ipcrm -s
                            echo "The program didn't clear semaphores"
                            exit 3
                        fi

                        named=$(find /dev/shm -user "$(whoami)" | wc -l)
                        if [ "$named" -ne 0 ]; then
                            find /dev/shm -user "$(whoami)" -delete
                            echo "The program didn't clear named semaphores"
                            exit 4
                        fi
					else
						echo "Probably deadlocked, program couldn't finish within 20 seconds with arguments" $a $b $c $d $e
						exit 5
					fi
					if [ "$wasInt" -eq 1 ]; then
					    exit 0
					fi
				done
			done
		done
	done	
done
