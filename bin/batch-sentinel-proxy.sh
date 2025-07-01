#!/bin/sh
mydir=$(cd "$(dirname "$0")"; pwd)
myname=$(basename $0)

# 初始化变量
SENTINEL_PREFIX=""
START_PORT=""
END_PORT=""
SENTINEL_ADDR=""
MEMORY=""
AUTH=""

# 新增 help 方法
help() {
    cat <<EOF
Usage: $0 -s <SENTINEL_PREFIX> -p <START_PORT> -e <END_PORT> -l <SENTINEL_ADDR> -m <MEMORY> -a <AUTH>

Options:
  -s <SENTINEL_PREFIX>   Sentinel prefix for naming instances (e.g., master). [哨兵前缀，用于命名实例（例如，master）]
  -p <START_PORT>        Starting port number for master instances. [主实例的起始端口号]
  -e <END_PORT>          Ending port number for master instances. [主实例的结束端口号]
  -l <SENTINEL_ADDR>     Comma-separated list of sentinel addresses (e.g., 192.168.1.1:26379,192.168.1.2:26379). [哨兵地址列表，以逗号分隔（例如，192.168.1.1:26379,192.168.1.2:26379）]
  -m <MEMORY>            Memory limit for Redis instances (e.g., 512M). [Redis实例的内存限制（例如，512M）]
  -a <AUTH>              Authentication password for Redis instances. [Redis实例的认证密码]
  -h                     Display this help message. [显示此帮助信息]

Examples:
  1. Start master and proxy instances with specified parameters:
     $0 -s master -p 6000 -e 6002 -l "192.168.1.1:26379,192.168.1.2:26379" -m 512M -a "password"
     [使用指定参数启动主实例和代理实例]

  2. Display help:
     $0 -h
     [显示帮助信息]
EOF
}

# 参数解析
while getopts ":s:p:e:l:m:a:h" opt; do
    case $opt in
        s)
            SENTINEL_PREFIX=$OPTARG
            ;;
        p)
            START_PORT=$OPTARG
            ;;
        e)
            END_PORT=$OPTARG
            ;;
        l)
            SENTINEL_ADDR=$OPTARG
            ;;
        m)
            MEMORY=$OPTARG
            ;;
        a)
            AUTH=$OPTARG
            ;;
        h)
            help
            exit 0
            ;;
        ?)
            echo "Invalid option: -$OPTARG" >&2
            help
            exit 1
            ;;
    esac
done

# 校验参数
if [ -z "$SENTINEL_PREFIX" ] || [ -z "$START_PORT" ] || [ -z "$END_PORT" ] || [ -z "$SENTINEL_ADDR" ] || [ -z "$MEMORY" ] || [ -z "$AUTH" ]; then
    echo "Missing required parameters."
    help
    exit 1
fi

# 自动生成端口号和哨兵名列表
PORTS=""
SENTINEL_NAMES=""
for ((port=START_PORT; port<=END_PORT; port++)); do
    PORTS+="$port,"
    SENTINEL_NAMES+="${SENTINEL_PREFIX}-${port},"
done
PORTS=${PORTS%,}  # 去掉最后一个逗号
SENTINEL_NAMES=${SENTINEL_NAMES%,}

# 检查 redis-start.sh 是否存在
REDIS_START_SCRIPT="${mydir}/redis-start.sh"

# 启动 master 实例
echo "Starting master instances..."
sh ${mydir}/redis-start.sh -p $PORTS -t master -m $MEMORY -a $AUTH -s $SENTINEL_NAMES -l $SENTINEL_ADDR

# 启动 proxy 实例
PROXY_PORTS=""
for port in ${PORTS//,/ }; do
    PROXY_PORTS+="1$port,"
done
PROXY_PORTS=${PROXY_PORTS%,}  # 去掉最后一个逗号

echo "Starting proxy instances..."
sh ${mydir}/redis-start.sh -p $PROXY_PORTS -t proxy -m $MEMORY -a $AUTH -s $SENTINEL_NAMES -l $SENTINEL_ADDR