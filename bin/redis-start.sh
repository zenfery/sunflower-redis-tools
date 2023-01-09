## redis 启动
## 参数解释
# -p : 安装的端口号列表, 多个端口号使用英文逗号隔开
# -t : 安装的 redis 实例的类型，可取值: master, slave, proxy; 默认取值: master
# -m : redis实例的最大内存, 例如: 1G, 200M; 默认 1G
# -a : redis 密码
# -s : 启动端口对应的 哨兵的名称列表, 以逗号分隔
#      若启动类型为 master ，则此为监控 master 的哨兵名称, 一个端口只能对应一个哨兵名
#      若启动类型为 proxy ，则此为代理到哪个 哨兵名，一个代理端口可以对应多个哨兵名，多个哨兵名采用:分隔, 多个哨兵名之间为 hash 分片
# -l : 哨兵地址列表，用于将 redis master 加入哨兵 (type=master时有效)
# -r : 用于指定redis master ip，用于将 master 加入到哨兵时用，若不传将取本机的IP
# -f : 用于主从模式指定redis master，可一次指定多个，与 -p 指定的端口号列表一一对应，格式: 127.0.0.1:4001,127.0.0.1:4011 (type=slave时有效)

mydir=$(cd "$(dirname "$0")"; pwd)
myname=$(basename $0)

#EXEC=/usr/local/bin/redis-server
#EXEC=/opt/apps/redis-5.0.14/src/redis-server
#CLIEXEC=/usr/local/bin/redis-cli
#CLIEXEC=/opt/apps/redis-5.0.14/src/redis-cli
#PROXYEXEC=/opt/apps/predixy-1.0.5/src/predixy

PORTS=""
SENTINEL_NAMES=""
SENTINEL_LISTS=""
MASTER_IP=""
TYPE="master"

#REDIS_CONF_DIR=/data/redis/redis-master-slave-conf
#REDIS_RDB_DIR=/data/redis/rdb
TPL_REDIS_CONF="$mydir/../tpl/redis.conf.tpl"
REDIS_MAXMEMORY="1G"
REDIS_PASS="123456"
MASTER_ADRRS=""

#PREDIXY_CONF_DIR=/data/redis/predixy-conf
TPL_PREDIXY_CONF_DIR=$mydir/../tpl/predixy

# 加载配置文件
source $mydir/../conf/env.conf

# loadmodule section
LOADMODULE_SECTION=""

help() {
    echo "Usage:"
    echo "$myname -p <PORTS> [-t <TYPE>] [-m <1G>] -a <REDIS_PASS>"
    echo "  安装master示例(不加入哨兵): sh install-redis.sh -p 4001,4011 -t master -m 1G -a 87654321"
    echo "  安装master示例: sh install-redis.sh -p 4001,4011 -t master -m 1G -a 87654321 -s config-master-0,config-master-1 -l 127.0.0.1:26000,127.0.0.2:26000 -r 127.0.0.1"
    echo "  安装master示例: sh install-redis.sh -p 4001,4011 -t master -m 1G -a 87654321 -s config-master-0,config-master-1 -l 127.0.0.1:26000,127.0.0.2:26000 "
    echo "  安装slave示例: sh install-redis.sh -p 4102 -t slave -m 500M -a 87654321 -f 127.0.0.1:4101"
    echo "  安装proxy示例: sh install-redis.sh -p 14001,14011 -t proxy -a 87654321 -s config-master-0,config-master-1 "
    echo "  -p 7001,7002"
    echo "  -t salve -> 可取值: master, slave, proxy; 默认取值: master"
    echo "  -m 1G -> 例如: 1G, 200M; 默认 1G (type=master 或 slave 时有效)"
    echo "  -a 123456789 -> redis密码"
    echo "  -s openapi-master-0:openapi-master-1,openapi-master-2 -> 哨兵名列表, 与 -p 指定的端口列表相对应 (type=master 或 proxy 时有效)"
    echo "  -l 127.0.0.1:26000,127.0.0.2:26000 -> 哨兵地址列表，用于将master加入到哨兵监控 (type=master时有效)"
    echo "  -r 127.0.0.1 -> redis master ip，用于将 master 加入到哨兵时用，若不传将取本机的IP (type=master时有效)"
    echo "  -f 127.0.0.1:4001,127.0.0.1:4011 -> 用于主从模式 指定redis master，可一次指定多个，与 -p 指定的端口号列表一一对应，格式: 127.0.0.1:4001,127.0.0.1:4011 (type=slave时有效)"
    exit -1
}

while getopts ":p:t:m:a:s:l:r:f:h" opt; do
    case $opt in
        p)
            echo "      -p: $OPTARG (PORTS)"
            PORTS=$OPTARG
            ;;
        t)
            echo "      -t: $OPTARG (TYPE)"
            TYPE=$OPTARG
            ;;
        m)
            echo "      -m: $OPTARG (REDIS_MAXMEMORY)"
            REDIS_MAXMEMORY=$OPTARG
            ;;
        a)
            echo "      -a: $OPTARG (REDIS_PASS)"
            REDIS_PASS=$OPTARG
            ;;
        s)
            echo "      -s: $OPTARG (SENTINEL_NAMES)"
            SENTINEL_NAMES=$OPTARG
            ;;
        l)
            echo "      -l: $OPTARG (SENTINEL_LISTS)"
            SENTINEL_LISTS=$OPTARG
            ;;
        r)
            echo "      -r: $OPTARG (MASTER_IP)"
            MASTER_IP=$OPTARG
            ;;
        f)
            echo "      -f: $OPTARG (MASTER_ADRRS)"
            MASTER_ADRRS=$OPTARG
            ;;
        h)
            help
            ;;
        ?)
            help
            ;;
    esac
done

## 获取本机IP
local_ip=""
local_ip_arr=`ifconfig | grep "inet " | grep -v 127.0.0.1 | awk '{print $2}'`
local_ip=${local_ip_arr[0]}
#echo "local_ip_arr: $local_ip_arr"
echo "local_ip: $local_ip"
if [ -z "$MASTER_IP" ]; then
    MASTER_IP=${local_ip}
fi
echo "MASTER_IP: $MASTER_IP"


## 校验参数



## 安装启动
mkdir -p $REDIS_LOG_DIR
mkdir -p $REDIS_RDB_DIR
mkdir -p $REDIS_CONF_DIR
mkdir -p $REDIS_PID_DIR

## redis-stack module 命令串
echo "REDIS_STACK_ENABLE: ${REDIS_STACK_ENABLE}"
echo "REDIS_STACK_INSTALL_DIR: ${REDIS_STACK_INSTALL_DIR}"
if [ "${REDIS_STACK_ENABLE}" = "yes" -a ! -z "${REDIS_STACK_INSTALL_DIR}" ];then
    EXEC="${REDIS_STACK_INSTALL_DIR}/bin/redis-server"
    CLIEXEC="${REDIS_STACK_INSTALL_DIR}/bin/redis-cli"
    echo "配置参数 REDIS_STACK_ENABLE : ${REDIS_STACK_ENABLE}, 启动 redis stack 模式。"
    echo "EXEC : ${EXEC}"
    echo "CLIEXEC : ${CLIEXEC}"
    LOADMODULE_SECTION="${LOADMODULE_SECTION}loadmodule ${REDIS_STACK_INSTALL_DIR}/lib/redisearch.so
"
    LOADMODULE_SECTION="${LOADMODULE_SECTION}loadmodule ${REDIS_STACK_INSTALL_DIR}/lib/redisgraph.so
"
    LOADMODULE_SECTION="${LOADMODULE_SECTION}loadmodule ${REDIS_STACK_INSTALL_DIR}/lib/redistimeseries.so
"
    LOADMODULE_SECTION="${LOADMODULE_SECTION}loadmodule ${REDIS_STACK_INSTALL_DIR}/lib/rejson.so
"
    LOADMODULE_SECTION="${LOADMODULE_SECTION}loadmodule ${REDIS_STACK_INSTALL_DIR}/lib/redisbloom.so
"
    echo "加载 redis stack module 配置如下: \n$LOADMODULE_SECTION"
fi

port_arr=(${PORTS//,/ })
sentinel_arr=(${SENTINEL_NAMES//,/ })
master_arr=(${MASTER_ADRRS//,/ })
#for port in ${port_arr[@]}; do
for i in ${!port_arr[@]}; do
    #echo "i: $i"
    port=${port_arr[$i]}
    echo "====> 开始安装 redis $TYPE 实例 [$port] ..."

    if [ $TYPE = "master" -o $TYPE = "slave" ]; then
        export REDIS_PORT=$port
        export REDIS_PASS
        export REDIS_MAXMEMORY
        export REDIS_RDB_DIR
        export REDIS_LOG_DIR
        export REDIS_PID_DIR
        export LOADMODULE_SECTION

        ## slave 对应的master
        if [ $TYPE = "slave" ]; then
            m_inst=${master_arr[$i]}
            if [ -z $m_inst ]; then
                ## 若多个slave使用
                m_inst=${master_arr[0]}
                echo " $port use master: $m_inst"
            fi
            m_inst_arr=(${m_inst//:/ })
            m_inst_host=${m_inst_arr[0]}
            m_inst_port=${m_inst_arr[1]}
            export REPLICAOF="replicaof $m_inst_host $m_inst_port"
        fi

        mkdir -p $REDIS_RDB_DIR/$port/
        pidfile=${REDIS_PID_DIR}/redis_${port}.pid

        ## 关闭旧的启动进程
        if [ ! -f $pidfile ]; then
            echo " $pidfile does not exist, process is not running"
        else
            PID=$(cat $pidfile)
            echo " Stopping ${port} ..."
            $CLIEXEC -p $port -a $REDIS_PASS shutdown
            while [ -x /proc/${PID} ]
            do
                echo " Waiting for Redis [${port}] to shutdown ..."
                sleep 1
            done
            echo " Redis [${port}] stopped"
        fi

        ## 生成配置文件
        config_file=$REDIS_CONF_DIR/redis.${port}.conf
        echo " port: $port -> config_file: $config_file"
        envsubst < $TPL_REDIS_CONF > $config_file

        ## 启动redis进程
        if [ -f "$config_file" ];then
            echo " redis config file is : $config_file, to start ${port}..."
            $EXEC $config_file
            echo " >>> start redis $port finish!!!"
        fi

        ## 如果是 master 进程，则将其加入到哨兵中
        if [ $TYPE = "master" ]; then
            stn_name=""
            if [ ! -z "${SENTINEL_NAMES}" ]; then
                stn_name=${sentinel_arr[$i]}
            fi
            sentinel_cluster_arr=(${SENTINEL_LISTS//,/ })
            for stnc in ${sentinel_cluster_arr[@]}; do
                stnc_ins_arr=(${stnc//:/ })
                s_host=${stnc_ins_arr[0]}
                s_port=${stnc_ins_arr[1]}
                $CLIEXEC -h ${s_host} -p ${s_port} sentinel monitor $stn_name $MASTER_IP $port 2
                $CLIEXEC -h ${s_host} -p ${s_port} sentinel set $stn_name auth-pass $REDIS_PASS
            done
        fi

    elif [ $TYPE = "proxy" ]; then
        export PREDIXY_PORT=$port
        export REDIS_PASS

        PREDIXY_SENTINELS=""
        ## 代理对应的哨兵列表
        if [ ! -z "${SENTINEL_NAMES}" ]; then
            sentinels=${sentinel_arr[$i]}
            #echo " sentinel $i : $sentinels"
            stn_arr=(${sentinels//:/ })
            for stn in ${stn_arr[@]}; do
                PREDIXY_SENTINELS="${PREDIXY_SENTINELS}    Group $stn {
"
                PREDIXY_SENTINELS="${PREDIXY_SENTINELS}    }
"
            done
        fi
        export PREDIXY_SENTINELS

        ## 生成 predixy 配置文件
        config_dir=$PREDIXY_CONF_DIR/$port
        if [ -d "$config_dir" ]; then
            echo " $config_dir exists, first delete it..."
            rm -rf $config_dir
        fi
        mkdir -p $config_dir
        envsubst < $TPL_PREDIXY_CONF_DIR/predixy.conf.tpl > $config_dir/predixy.conf
        envsubst < $TPL_PREDIXY_CONF_DIR/auth.conf.tpl > $config_dir/auth.conf
        envsubst < $TPL_PREDIXY_CONF_DIR/sentinel.conf.tpl > $config_dir/sentinel.conf
        envsubst < $TPL_PREDIXY_CONF_DIR/latency.conf.tpl > $config_dir/latency.conf

        config_file=$config_dir/predixy.conf
        if [ -f "$config_file" ];then
            # kill 旧进程
            PID=`ps -ef| grep predixy | grep -v grep | grep $port | awk '{print $2}'`
            if [ ! -z "$PID" ];then
                echo " $port exists, first kill it..."
                kill $PID
                while [ -x /proc/${PID} ]
                do
                    echo " Waiting for proxy [${port}] to shutdown ..."
                    sleep 1
                done
                echo " proxy [${port}] stopped"
            fi
            echo " redis proxy config file is : $config_file, to start ${port}..."
            $PROXYEXEC $config_file &
            echo " >>> start redis proxy $port finish!!!"
        fi
    fi
done