#!/bin/bash
if [ -f /opt/st/stm32mp2/5.0.3-snapshot/environment-setup-cortexa35-ostl-linux ]; then
    echo "作者：dengzhimao@alientek.com"
    echo "欢迎您来到SystemUI一键编译脚本程序！"
    echo "Copyright 2024-2030 Guangzhou ALIENTEK Electronincs Co.,Ltd. All rights reserved"
else
    echo "警告：请按根据ATK-DLRK3588网盘资料下/10用户手册/辅助文档/基于Buildroot系统_交叉编译器安装与使用参考手册，安装交叉编译器再编译!"
    exit -1
fi
source /opt/st/stm32mp2/5.0.3-snapshot/environment-setup-cortexa35-ostl-linux

do_compile() {
for projectpath in `ls .`; do
    #echo $projectpath
    pro=$(ls -1 "$projectpath"/*.pro 2>/dev/null)
    if [ $? -eq 0 ]; then
	cd $projectpath
        qmake "$projectpath".pro
	echo "正在编译 $projectpath"
	make -j 8
	if [ $? -ne 0 ]; then
	  return -1
	fi
	cd - 2>&1 > /dev/null
    	fi
done
}

do_cleanall() {
for projectpath in `ls .`; do
    #echo $projectpath
    pro=$(ls -1 "$projectpath"/*.pro 2>/dev/null)
    if [ $? -eq 0 ]; then
        cd $projectpath
        echo "正在清理 $projectpath"
	if [ -f ./Makefile ]; then
            make distclean -j 16 2>&1 >/dev/null
    	fi
	cd - 2>&1 > /dev/null
        fi
done
}

usage()
{
	echo "Usage: $(basename $BASH_SOURCE) [OPTIONS]"
	echo "Available options:"

	# Global options
	echo -e "cleanall                          \t清除SystemUI项目所有编译内容"
	echo -e "all				   \t进入当前目录下的所有1级文件夹编译Qt项目，编译全部"
	echo -e "help                              \tusage"
	echo ""
	echo "Default option is 'all'."

	exit 0
}

do_check() {
if [ $? -ne 0 ]; then
    echo
    echo "编译失败！请检查SystemUI失败项目再重新编译！"
    echo
    exit 1
else
    echo 
    echo "编译完成！全部项目编译成功！"
    echo 
fi
}
OPTIONS=${@:-all}

for opt in $OPTIONS; do
	case "$opt" in
		help | h | -h | --help | usage | \?) usage ;;
		cleanall)
		echo ""
		echo "正在清除编译内容"
		echo ""
		do_cleanall
		;;
		all)
		echo ""
		echo "开始编译项目，生成的可执行文件位于ui文件夹中，拷贝整个ui文件夹到系统/opt文件夹下，
		执行/opt/ui/systemui启动系统桌面"
		echo ""
		do_compile
		do_check
		;;
		*)
		echo "无效参数: $opt"
		usage
		;;
	esac
done


