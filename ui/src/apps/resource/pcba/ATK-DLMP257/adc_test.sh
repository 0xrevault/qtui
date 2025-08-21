#!/bin/bash
for i in {1..1000}; do
	 echo $(awk "BEGIN{printf (\"%d\n\", ($(cat /sys/bus/iio/devices/iio:device0/in_voltage15_raw) + 0) * 0.439453125)}") mv
	sleep 1
done

