#!/bin/bash

# -----------------------------
# IP 组配置
# 格式：IP/掩码 网关 网卡名称
# 示例：
# GROUP1=("192.168.1.100/24 192.168.1.1 eth0" "10.0.0.100/24 10.0.0.1 eth1")
# GROUP2=("192.168.1.101/24 192.168.1.1 eth0" "10.0.0.101/24 10.0.0.1 eth1")
# -----------------------------
CONFIG_FILE="/etc/network/interfaces.d/50-cloud-init"

GROUP1=("1.1.1.2/26 1.1.1.1 eth0" "2.2.2.2/26 2.2.2.1 eth0:0")
GROUP2=("3.3.3.3/26 3.3.3.1 eth0" "4.4.4.4/26 4.4.4.1 eth0:0")

# 定义一个数组，包含所有IP组
IP_GROUPS=(GROUP1 GROUP2)

# 脚本所在的文件夹路径，用于 cron 作业找到脚本
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)"

# 当前使用的 IP 组索引，用于轮换
CURRENT_INDEX_FILE="$SCRIPT_DIR/current_index"

# 读取当前的 IP 组索引，如果文件不存在则创建并初始化为 0
if [ ! -f "$CURRENT_INDEX_FILE" ]; then
    echo 0 > "$CURRENT_INDEX_FILE"
fi
CURRENT_INDEX=$(cat "$CURRENT_INDEX_FILE")

# 计算下一个 IP 组索引
NEXT_INDEX=$(( (CURRENT_INDEX + 1) % ${#IP_GROUPS[@]} ))

# 更新索引文件
echo "$NEXT_INDEX" > "$CURRENT_INDEX_FILE"

# 获取下一个 IP 组
NEXT_GROUP_NAME=${IP_GROUPS[$NEXT_INDEX]}
eval "NEXT_GROUP=(\"\${${NEXT_GROUP_NAME}[@]}\")"

# 清空当前网络配置
> $CONFIG_FILE

# 遍历 IP 组并配置网络
for ip_info in "${NEXT_GROUP[@]}"; do
    IFS=' ' read -r ip gateway iface <<< "$ip_info"
    echo $ip_info
    # 判断操作系统类型并修改配置文件
    if [[ -f "/etc/debian_version" ]]; then
        # Debian/Ubuntu 系统

        # 判断是否是虚拟接口
        if [[ "$iface" == *:* ]]; then
            cat >> $CONFIG_FILE <<EOF
auto $iface
iface $iface inet static
    address $ip
EOF
        else
            cat >> $CONFIG_FILE <<EOF
auto $iface
iface $iface inet static
    address $ip
    gateway $gateway
EOF
        fi
    elif [[ -f "/etc/redhat-release" ]]; then
        # CentOS/RHEL 系统
        cat >> $CONFIG_FILE <<EOF
DEVICE=$iface
BOOTPROTO=none
ONBOOT=yes
IPADDR=$ip
GATEWAY=$gateway
EOF
    fi
done

# 重启网络，生效配置
if [[ -f "/etc/debian_version" ]]; then
    # Debian/Ubuntu 系统使用 systemctl 命令重启 networking 服务
    systemctl restart networking
elif [[ -f "/etc/redhat-release" ]]; then
    # CentOS/RHEL 7+ 系统使用 systemctl 重启 network 服务
    systemctl restart network
fi