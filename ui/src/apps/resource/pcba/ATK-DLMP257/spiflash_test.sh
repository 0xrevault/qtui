#!/bin/sh
#check
if [ ! -e "/dev/mtdblock0" ]; then
		echo "do not find /dev/mtdblock0, spi norflash w25q128 check failed."
    	exit 1
fi

#format
mkfs.vfat /dev/mtdblock0
if [ ! $? -eq 0 ]; then
		echo "failed: mkfs.vfat /dev/mtdblock0"
    	exit 1
fi

#write
mkdir -p /home/root/shell/norflash/w25q128_flash_test
mount -t vfat /dev/mtdblock0 /home/root/shell/norflash/w25q128_flash_test
TEST_STR="W25Q128 TEST"
echo $TEST_STR > /home/root/shell/norflash/w25q128_flash_test/file.txt
sync
cd /home/root/shell/
umount /dev/mtdblock0

#read
mount -t vfat /dev/mtdblock0 /home/root/shell/norflash/w25q128_flash_test
READ_STR=$(cat /home/root/shell/norflash/w25q128_flash_test/file.txt)

#remove
umount /dev/mtdblock0
rm -rf /home/root/shell/norflash/

#compare
if [ "$READ_STR" = "$TEST_STR" ]; then
	echo "spi norflash w25q128 test successful"
	exit 0
else
	echo "spi norflash w25q128 test failed"
	exit 1
fi
