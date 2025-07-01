#!/usr/bin/env python2
# -*- coding: utf-8 -*-

import sys
import socket
from collections import defaultdict
import subprocess  # 新增：用于调用 redis-cli 命令
import os  # 新增：用于获取配置文件路径
from table_printer import print_table  # 引入新模块


def parse_args():
    """解析命令行参数并生成 host:port 组合"""
    if len(sys.argv) < 5 or sys.argv[1] == '--help':
        print("Usage: {} --hosts <hosts> --ports <ports> [--pass <password>]".format(sys.argv[0]))
        print("Example: {} --hosts 127.0.0.1,127.0.0.2 --ports 6379,6380 [--pass yourpassword]".format(sys.argv[0]))
        sys.exit(1)

    hosts = sys.argv[sys.argv.index('--hosts') + 1].split(',')
    ports = sys.argv[sys.argv.index('--ports') + 1].split(',')

    # 新增：解析 --pass 参数
    password = None
    if '--pass' in sys.argv:
        password_index = sys.argv.index('--pass') + 1
        if password_index < len(sys.argv):
            password = sys.argv[password_index]

    # 生成所有 host:port 组合
    host_port_combinations = []
    for host in hosts:
        for port in ports:
            host_port_combinations.append((host, port))

    return host_port_combinations, password


def get_redis_cli_path():
    """从 env.conf 文件中获取 redis-cli 的路径"""
    mydir = os.path.dirname(os.path.abspath(__file__))
    conf_path = os.path.join(mydir, "../conf/env.conf")
    with open(conf_path, 'r') as f:
        for line in f:
            if line.startswith("CLIEXEC="):
                return line.strip().split("=")[1]
    return "redis-cli"  # 默认值


def check_redis(host, port, password=None):
    """检查 Redis 实例是否可用并返回角色"""
    try:
        # 尝试导入 redis 模块
        import redis
        r = redis.StrictRedis(host=host, port=int(port), socket_timeout=2, password=password)
        info = r.info()
        role = info.get('role', 'unknown')
        return True, role
    except ImportError:
        # 如果没有 redis 模块，使用 redis-cli 命令行工具
        redis_cli_path = get_redis_cli_path()  # 获取 redis-cli 路径
        cli_cmd = "%s -h %s -p %s --raw INFO" % (redis_cli_path, host, port)

        # 设置 REDISCLI_AUTH 环境变量
        if password:
            os.environ['REDISCLI_AUTH'] = password

        try:
            result = subprocess.check_output(cli_cmd, shell=True).decode('utf-8')
            for line in result.splitlines():
                if line.startswith("role:"):
                    role = line.split(":")[1]
                    return True, role
            return False, "Unable to determine role"
        except Exception as e:
            return False, str(e)
        finally:
            # 清除 REDISCLI_AUTH 环境变量
            if 'REDISCLI_AUTH' in os.environ:
                del os.environ['REDISCLI_AUTH']
    except Exception as e:
        return False, str(e)


def check_predixy(host, port):
    """检查 Predixy 代理是否可用"""
    predixy_port = int("1" + str(port)) # 修改：Predixy 端口规则为 Redis 端口前加 1
    # print("Checking Predixy proxy on %s:%s" % (host, predixy_port))
    sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
    sock.settimeout(2)
    try:
        sock.connect((host, predixy_port))
        sock.close()
        return True, None
    except Exception as e:
        print("Error connecting to Predixy proxy on %s:%s: %s" % (host, predixy_port, str(e)))
        return False, str(e)


def main():
    host_port_combinations, password = parse_args()

    results = defaultdict(lambda: defaultdict(dict))

    # 收集所有端口
    all_ports = set()
    for _, port in host_port_combinations:
        all_ports.add(port)

    # 检查每个 host:port 组合
    for host, port in host_port_combinations:
        # 检查 Redis
        redis_status, redis_role = check_redis(host, port, password)
        results[host]['redis'][port] = {'status': redis_status, 'role': redis_role}

        # 检查 Predixy
        predixy_status, predixy_error = check_predixy(host, port)
        results[host]['predixy'][port] = {'status': predixy_status, 'error': predixy_error}

    # 构建表格数据
    headers = ["Port"]
    for host in {h for h, _ in host_port_combinations}:
        headers.extend(["%s-Master" % host, "%s-Slave" % host, "%s-Proxy" % host])

    rows = []
    for port in sorted(all_ports, key=lambda x: int(x)):
        row = {"Port": port}
        for host in {h for h, _ in host_port_combinations}:
            redis_info = results[host]['redis'].get(port, {})
            predixy_info = results[host]['predixy'].get(port, {})
            master_status = "OK" if redis_info.get('role') == 'master' else "-"
            slave_status = "OK" if redis_info.get('role') == 'slave' else "-"
            proxy_status = "OK" if predixy_info.get('status') else "ERROR"
            row["%s-Master" % host] = master_status
            row["%s-Slave" % host] = slave_status
            row["%s-Proxy" % host] = proxy_status
        rows.append(row)

    # 使用新模块打印表格
    print_table(headers, rows)

if __name__ == "__main__":
    main()