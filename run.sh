#!/bin/sh

/opt/oracle/opmn/bin/opmnctl startall
while true 
do
	if [ `pgrep -f 'httpd|opmn|java' | wc -l` -eq 0 ]
	then
		break
	fi
	sleep 10
done
		
