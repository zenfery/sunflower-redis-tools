################################## NETWORK #####################################
#bind 127.0.0.1
# 保护模式，开启后，需要设置 bind 或 requirepass
#protected-mode yes
port ${REDIS_PORT}
tcp-backlog 511
timeout 0
tcp-keepalive 60

################################# GENERAL #####################################

daemonize yes
supervised no
pidfile "${REDIS_PID_DIR}/redis_${REDIS_PORT}.pid"
loglevel notice
logfile "${REDIS_LOG_DIR}/redis.${REDIS_PORT}.log"
databases 16
always-show-logo yes

################################ SNAPSHOTTING  ################################
save ""
stop-writes-on-bgsave-error yes
rdbcompression yes
rdbchecksum yes
#dbfilename dump.rdb
dir "${REDIS_RDB_DIR}/${REDIS_PORT}"

################################# REPLICATION #################################
# replicaof <masterip> <masterport>
${REPLICAOF}
masterauth "${REDIS_PASS}"
replica-serve-stale-data yes
replica-read-only yes
repl-diskless-sync no
repl-diskless-sync-delay 5
repl-disable-tcp-nodelay no
replica-priority 100

################################## SECURITY ###################################

requirepass "${REDIS_PASS}"

################################### CLIENTS ####################################

maxclients 100000

############################## MEMORY MANAGEMENT ################################

maxmemory ${REDIS_MAXMEMORY}
maxmemory-policy allkeys-lru

############################# LAZY FREEING ####################################

lazyfree-lazy-eviction no
lazyfree-lazy-expire no
lazyfree-lazy-server-del no
replica-lazy-flush no

############################## APPEND ONLY MODE ###############################

appendonly no
appendfilename "appendonly.aof"
appendfsync everysec
no-appendfsync-on-rewrite no
auto-aof-rewrite-percentage 100
auto-aof-rewrite-min-size 64mb
aof-load-truncated yes
aof-use-rdb-preamble yes

################################ LUA SCRIPTING  ###############################

lua-time-limit 5000

################################## SLOW LOG ###################################

slowlog-log-slower-than 10000
slowlog-max-len 128

################################ LATENCY MONITOR ##############################

latency-monitor-threshold 0

############################# EVENT NOTIFICATION ##############################

notify-keyspace-events ""

############################### ADVANCED CONFIG ###############################

hash-max-ziplist-entries 512
hash-max-ziplist-value 64
list-max-ziplist-size -2
list-compress-depth 0
set-max-intset-entries 512
zset-max-ziplist-entries 128
zset-max-ziplist-value 64
hll-sparse-max-bytes 3000
stream-node-max-bytes 4096
stream-node-max-entries 100
activerehashing yes
client-output-buffer-limit normal 0 0 0
client-output-buffer-limit replica 256mb 64mb 60
client-output-buffer-limit pubsub 32mb 8mb 60
# client-query-buffer-limit 1gb
# proto-max-bulk-len 512mb
hz 10
dynamic-hz yes
aof-rewrite-incremental-fsync yes
rdb-save-incremental-fsync yes
# lfu-log-factor 10
# lfu-decay-time 1

########################### ACTIVE DEFRAGMENTATION #######################
# activedefrag yes
# active-defrag-ignore-bytes 100mb
# active-defrag-threshold-lower 10
# active-defrag-threshold-upper 100
# active-defrag-cycle-min 5
# active-defrag-cycle-max 75
# active-defrag-max-scan-fields 1000
# server_cpulist 0-7:2
# bio_cpulist 1,3
# aof_rewrite_cpulist 8-11
# bgsave_cpulist 1,10-11
# ignore-warnings ARM64-COW-BUG

## loadmodule
${LOADMODULE_SECTION}