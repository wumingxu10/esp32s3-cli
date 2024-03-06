#!/bin/bash

if [ $# -ne 2 ]; then
    echo "Usage: $0 <serial_port> <baud>" 
    exit 1
fi
#++++++++++++++++ 串口参数设置+++++++++++++++++++++
#目标串口设置  /dev/ttyUSB*
fdtty=$1
#波特率设置 
baud=$2
#+++++++++++++++++++++++++++++++++++++++++++++++++++
tp="/tmp/$(date +%N).txt"

exUsb(){
	if [ ! -c $fdtty ];then
		echo "不存在目标串口($fdtty)！退出脚本"
		exit 0
	fi
}

#键盘输入
getData(){ 
	while((1))
	do	
		exUsb	
		read readd
		echo -e -n "$readd\n" > $fdtty
	done
}

#串口有数据接收时就返回
dis(){
	while ((1))
	do
		exUsb
		cat $fdtty >> $tp
		#cat $fdtty  >> /tmp/usbget.txt
		if [[ -s $tp ]];then
			cat $tp
			cat /dev/null > $tp #显示过的就在文件中清除
		fi
	done
}
info(){
	echo "Welcome to mtty"
	echo "OPTIONS: baud:$baud"
	echo "Port $fdtty"
	echo "Quit by 'CTRL-C'"
	echo ""
}
main(){
	info
	exUsb
	stty -F $fdtty -echo raw speed $baud  min 0 time 2 &> /dev/null
	#echo -e -n "\n" >$fdtty #启动时发送，以获取反馈显示
	dis &    #显示线程
	getData  #键盘输入线程
	exit 0	
}

main 