#!/bin/sh
/usr/bin/ffmpeg -ss 00:00:00 -i "$1" -vf "select=eq(n\,5)" -vframes 1 "$2"
