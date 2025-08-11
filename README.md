# sunflower-redis-tools
redis 操作工具集

[TOC]

## 概述


## 支持的功能
- 支持安装单体 redis。
- 支持安装 redis master/slave。
- 支持安装 redis 代理: predixy。
- 支持 redis stack 的安装。

## 使用指南
### 准备工作
在使用 `redis-start.sh` 之前，需要先安装 redis 执行程序（包含 redis-server、redis-cli 等命令），若需要使用 redis-stack(如：redisjson)，则需要安装官方 redis-stack 二进制包（包含 lib/re*.so 相关redis模块）。
> redis源码包下载地址：https://download.redis.io/releases/

#### 配置文件修改
在使用工具命令前，先修改配置文件`conf/env.conf`。
### redis-start.sh 使用
```bash
## 执行命令查看帮助
bin/redis-start.sh -h
```

**使用示例：**

```bash
### 在单机上安装批量安装一批 master 类型的redis：端口 6379～6410共32个实例
for i in $(seq 6379 6410); do
  sh sunflower-redis-tools-1.1.0/bin/redis-start.sh -t master -m 3G -p $i -a 123456
done

### 另一种方式：-p 参数直接传入所有端口列表
sh sunflower-redis-tools-1.1.0/bin/redis-start.sh -t master -m 3G -p 6379,6380,6381,6382,6383,6384,6385,6386,6387,6388,6389,6390,6391,6392,6393,6394,6395,6396,6397,6398,6399,6400,6401,6402,6403,6404,6405,6406,6407,6408,6409,6410 -a 123456

##端口列表可以使用以下命令生成
for i in $(seq 6379 6410); do
  echo -n "$i,"
done
```



### redis-check.py 使用

Redis健康检查工具，用于验证Redis实例连接状态、主从角色识别及Predixy代理可达性检测。

**功能特性**：
- 自动识别主从角色（通过`INFO replication`）
- 验证Redis连接状态
- 检测Predixy代理可达性（端口规则：Redis端口前加`1`）
- 支持密码认证（通过`--pass`参数）
- 输出表格化结果便于阅读

**参数说明**：
```
## 执行命令查看帮助
bin/redis-check.py -h
```

### batch-sentinel-proxy.sh 使用说明
Redis哨兵模式批量部署工具，用于快速启动带哨兵监控的Redis主从实例及对应代理服务。

**核心功能**：

- 批量创建指定端口范围的Redis主实例
- 自动关联指定哨兵集群
- 同步启动Predixy代理服务（端口规则：Redis端口前加`1`）
- 支持内存限制和密码认证配置

**参数说明**：
```
## 执行命令查看帮助
bin/batch-sentinel-proxy.sh -h
```

**使用示例**：
```bash
# 启动端口6000-6002的主实例及代理
bin/batch-sentinel-proxy.sh \
  -s master \
  -p 6000 \
  -e 6002 \
  -l "192.168.1.1:26379,192.168.1.2:26379" \
  -m 512M \
  -a "yourpassword"

# 查看帮助信息
bin/batch-sentinel-proxy.sh -h
```


### 构建打包
```bash
build.sh
```
输出安装包位于 build 目录下，如 build/sunflower-redis-tools-1.0.0.tar 。