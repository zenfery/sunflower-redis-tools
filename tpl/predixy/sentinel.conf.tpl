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
    Sentinels {
        + 10.144.14.165:26000
        + 10.160.62.17:26000
        + 10.160.61.171:26000
    }
${PREDIXY_SENTINELS}
}
