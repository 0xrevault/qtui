#!/bin/bash
amixer cset name='PCM Volume' 192 > /dev/null 2>&1
amixer cset name='Mono Mux' 'Stereo' > /dev/null 2>&1
amixer cset name='Playback De-emphasis' 2 > /dev/null 2>&1
amixer cset name='Capture Digital Volume' 192 > /dev/null 2>&1
amixer cset name='Capture Mute' 'on' > /dev/null 2>&1
amixer cset name='Capture Polarity' 'Normal' > /dev/null 2>&1
amixer cset name='3D Mode' 'No 3D' > /dev/null 2>&1
amixer cset name='ALC Capture Attack Time' 5 > /dev/null 2>&1
amixer cset name='ALC Capture Decay Time' 2 > /dev/null 2>&1
amixer cset name='ALC Capture Function' 'Stereo' > /dev/null 2>&1
amixer cset name='ALC Capture Hold Time' 2 > /dev/null 2>&1
amixer cset name='ALC Capture Max PGA' 3 > /dev/null 2>&1
amixer cset name='ALC Capture Min PGA' 6 > /dev/null 2>&1
amixer cset name='ALC Capture NG Switch' 'on' > /dev/null 2>&1
amixer cset name='ALC Capture NG Threshold' 9 > /dev/null 2>&1
amixer cset name='ALC Capture NG Type' 'Mute ADC Output' > /dev/null 2>&1
amixer cset name='ALC Capture Target Volume' 15 > /dev/null 2>&1
amixer cset name='ALC Capture ZC Switch' 'on' > /dev/null 2>&1
amixer cset name='Left Channel Capture Volume' 100% > /dev/null 2>&1
amixer cset name='Right Channel Capture Volume' 100% > /dev/null 2>&1
amixer cset name='Left Mixer Left Bypass Volume' 100% > /dev/null 2>&1
amixer cset name='Right Mixer Right Bypass Volume' 100% > /dev/null 2>&1
amixer cset name='Output 1 Playback Volume' 100% > /dev/null 2>&1
amixer cset name='Output 2 Playback Volume' 100% > /dev/null 2>&1
amixer cset name='ZC Timeout Switch' 'on' > /dev/null 2>&1
amixer cset name='Left PGA Mux' 'DifferentialL' > /dev/null 2>&1
amixer cset name='Right PGA Mux' 'DifferentialR' > /dev/null 2>&1

amixer cset name='Differential Mux' 'Line 2' > /dev/null 2>&1
amixer cset name='Left Line Mux' 'Line 2L' > /dev/null 2>&1
amixer cset name='Right Line Mux' 'Line 2R' > /dev/null 2>&1

for i in {1..1000}; do
	echo "当前状态正在录音，请讲话..."
	arecord -f cd -d 2 .record.wav
	echo "当前状态正在播放，请听..."
	aplay .record.wav
done

