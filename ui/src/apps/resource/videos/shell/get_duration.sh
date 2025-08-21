#!/bin/sh
ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 $1 | xargs -n 1 | while read -r duration; do
  echo "$duration/1" | bc -l | xargs printf "%.0f\n"
done
