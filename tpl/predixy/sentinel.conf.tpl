SentinelServerPool {
    Password ${REDIS_PASS}
    Databases 16
    Hash crc16
    HashTag "{}"
    Distribution modula
    MasterReadPriority 50
    StaticSlaveReadPriority 50
    DynamicSlaveReadPriority 50
    RefreshInterval 1
    ServerTimeout 3
    ServerFailureLimit 10
    ServerRetryTimeout 1
    KeepAlive 60
${PREDIXY_SENTINELS_HOST}
${PREDIXY_SENTINELS}
}
