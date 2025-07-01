#!/usr/bin/env python2
# -*- coding: utf-8 -*-

def print_table(headers, rows):
    """
    打印格式规整的表格。
    
    :param headers: 表头列表 (list of str)
    :param rows: 数据行列表，每行是一个字典 (list of dict)
    """
    # 计算每列的最大宽度
    col_widths = [max(len(str(item)) for item in [header] + [row.get(header, "") for row in rows]) for header in headers]

    # 打印表头
    header_line = " | ".join("%s" % header.ljust(width) for header, width in zip(headers, col_widths))
    print(header_line)
    print("-" * len(header_line))

    # 打印数据行
    for row in rows:
        row_data = [str(row.get(header, "")) for header in headers]
        print(" | ".join("%s" % data.ljust(width) for data, width in zip(row_data, col_widths)))