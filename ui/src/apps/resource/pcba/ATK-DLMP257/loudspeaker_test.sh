#!/bin/bash
aplay /usr/share/sounds/alsa/Front_Center.wav
echo "请听喇叭有没有声音！"
for i in {1..1000}; do
	aplay /usr/share/sounds/alsa/Front_Center.wav
	sleep 1
done
