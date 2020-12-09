#!/bin/sh

echo
echo "Kill and Restart..."

_PID=`cat KID`
_COM=`ps aux | grep $_PID | grep -v grep | awk '{ for(i=1;i<=NF;i++) {if ( i > 11 ) printf $i" "}; printf "\n" }'` 
#| sed 's/-w-web*//g'`

kill $_PID 2>web-tail.log
sleep 2
#kill $(lsof -t -i:8383) #/dev/null 2>&1
killall tail 2>>web-tail.log
sleep 2

echo "Starting script PID: ($_PID)"
#unblock-proxy.sh dns -p -d -w >web-sh.log 2>&1 &

if [ -z $_COM ]; then
    _COM="/usr/bin/unblock-proxy.sh dns -p -d"
fi

nohup $_COM >web-tail.log 2>&1 &

echo "done. re-run: $_COM"
exit 0;
