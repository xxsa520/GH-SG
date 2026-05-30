#!/bin/bash

echo "启动入口触发: $(date)"
echo "启动方式: $1" >> /tmp/start.log
echo "启动入口触发: $(date)" >> /tmp/start.log
cd /workspaces/GH-SG/python-xray-argo || exit 1

mkdir -p .cache

# ===== 强制重启 app.py =====
echo "强制重启 app.py"
pkill -f "app.py" 2>/dev/null
nohup python app.py > app.log 2>&1 &

# ===== 等待 sub.txt（带超时更安全）=====
TIMEOUT=600
COUNT=0

while [ ! -s .cache/sub.txt ]; do
    echo "等待 sub.txt..."
    sleep 5
    COUNT=$((COUNT+5))

    if [ $COUNT -ge $TIMEOUT ]; then
        echo "超时，退出等待"
        exit 1
    fi
done

echo "sub.txt 已生成"

# ===== 强制重启上传脚本 =====
echo "强制重启上传脚本"
pkill -f "shangchuanusb.sh" 2>/dev/null
cd /workspaces/GH-SG
chmod +x shangchuanusb.sh
nohup ./shangchuanusb.sh > usb.log 2>&1 &

echo "启动流程完成"
