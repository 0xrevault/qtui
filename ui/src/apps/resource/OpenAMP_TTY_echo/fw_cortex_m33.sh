#!/bin/sh

rproc_class_dir="/sys/class/remoteproc/remoteproc0/"
fmw_dir="/lib/firmware"
rproc_state=`tr -d '\0' < $rproc_class_dir/state`
fmw_name="OpenAMP_TTY_echo_CM33_NonSecure.elf"

if [ ! -e $(dirname "$0")/lib/firmware/${fmw_name} ]; then
      echo  "Error: signed firmware $(dirname "$0")/lib/firmware/${fmw_name} cannot be found"
      exit 1
fi

echo "`basename ${0}`: fmw_name=${fmw_name}"

if [ $rproc_state == "running" ]; then
    echo "Stopping running fw ..."
    echo stop > $rproc_class_dir/state
fi

# Create /lib/firmware directory if not exist
if [ ! -d $fmw_dir ]; then
    echo "Create $fmw_dir directory"
    mkdir $fmw_dir
fi

# Copy firmware in /lib/firmware
cp $(dirname "$0")/lib/firmware/$fmw_name $fmw_dir/

# load and start firmware
echo $fmw_name > $rproc_class_dir/firmware
echo start > $rproc_class_dir/state

msleep 500
