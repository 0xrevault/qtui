#!/bin/bash

INTERFACE="end0"

LINK_STATUS=$(ethtool $INTERFACE | grep "Link detected" | awk '{print $3}')

result1=$(ifconfig $INTERFACE | grep 'TX packets:' | awk '{print $2}' | sed 's/[^0-9]//g')
result2=$(ifconfig $INTERFACE | grep 'RX packets:' | awk '{print $2}' | sed 's/[^0-9]//g')

if [ "$LINK_STATUS" == "yes" ] && [ "$result1" -ne 0 ] && [ "$result2" -ne 0 ]; then
    echo "succeed"
    exit 0
else
    echo "failure"
    exit 1
fi
