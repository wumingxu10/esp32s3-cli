#!/bin/bash

# 检查是否提供了串口设备路径参数
if [ $# -ne 1 ]; then
    echo "Usage: $0 <serial_port>"
    exit 1
fi

SERIAL_PORT="$1" # 从命令行参数获取串口设备路径

# 检查串口设备是否存在
if [ ! -e "$SERIAL_PORT" ]; then
    echo "Error: Serial port $SERIAL_PORT not found"
    exit 1
fi

# 设置串口波特率
stty -F "$SERIAL_PORT" 9600 cs8 -cstopb -parenb

# 打开串口设备，同时将其文件描述符设为3
exec 3<> $SERIAL_PORT || {
    echo "Error: Unable to open serial port $SERIAL_PORT"
    exit 1
}

# 从串口读取数据，并打印到终端上
while true; do
    if read -r -t 0.1 line <&3; then
        echo "$line"
    else
        # 如果超时但之前有读取到数据，则打印已读取的数据
        if [ -n "$line" ]; then
            echo -n "$line"
        fi
    fi
done &

bg_pid=$! # 获取后台进程的PID

# 定义函数来关闭后台进程
cleanup() {
    echo "Cleaning up..."
    kill $bg_pid
    exit 0
}

# 捕获退出信号，并调用cleanup函数
trap cleanup EXIT

# 读取用户输入，并发送到串口
while true; do
    # 读取用户输入的命令
    read  command
    
    # 将用户输入的命令发送到串口
    echo  "$command" >&3
done
