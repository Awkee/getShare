# getShare
简单快速提取A股财务指标数据Shell脚本，同时可以自动生成mysql表结构建表语句及入库文件

## 如何使用

1. 配置 `get_data.sh`脚本，目录信息和`mysql`数据库信息(用户名/密码/数据库实例名)。
2. 执行`get_data.sh`脚本，下载数据并进行数据入库，这里使用了`mysqlimport`命令，请提前安装好。
3. 执行完`get_data.sh`脚本后，可以参考`exp_data.sh`脚本进行财务指标数据分析提取。


## 依赖说明
> 如果以下依赖命令没有请自行安装完再执行。

1. 需要 `curl`命令下载财务指标数据;
2. 需要`mysql`和`mysqlimport` 命令进行建表和数据入库。



