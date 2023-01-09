################################### GENERAL ####################################
Name PredixyMain
Bind 0.0.0.0:${PREDIXY_PORT}
WorkerThreads 1
ClientTimeout 300

################################### LOG ########################################
Log /data/logs/redis-logs/predixy.${PREDIXY_PORT}.log
LogRotate 1d
AllowMissLog true
LogVerbSample 0
LogDebugSample 0
LogInfoSample 10000
LogNoticeSample 1
LogWarnSample 1
LogErrorSample 1
################################### AUTHORITY ##################################
Include auth.conf

################################### SERVERS ####################################
# Include cluster.conf
Include sentinel.conf
# Include try.conf

################################### DATACENTER #################################
## LocalDC specify current machine dc
# LocalDC bj

## see dc.conf
# Include dc.conf


################################### COMMAND ####################################
## Custom command define, see command.conf
#Include command.conf

################################### LATENCY ####################################
## Latency monitor define, see latency.conf
Include latency.conf
