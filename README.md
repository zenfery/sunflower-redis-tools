# sunflower-redis-tools
redis 操作工具集

## 支持的功能
- 支持安装单体 redis。
- 支持安装 redis master/slave。
- 支持安装 redis 代理: predixy。
- 支持 redis stack 的安装。

## 使用指南
### 准备工作
在使用 `redis-start.sh` 之前，需要先安装 redis 程序（包含 redis-server、redis-cli 等命令），若需要使用 redis-stack(如：redisjson)，则需要安装官方 redis-stack 二进制包（包含 lib/re*.so 相关redis模块）。
### redis-start.sh 使用
```bash
## 执行命令查看帮助
bin/redis-start.sh -h
```

### 构建打包
```bash
build.sh
```
输出安装包位于 build 目录下，如 build/sunflower-redis-tools-1.0.0.tar 。