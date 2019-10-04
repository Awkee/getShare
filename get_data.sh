#!/bin/bash
#########################################################################
# File Name: get_zycwzb.sh
# Author: zwker
# mail: xiaoyu0720@gmail.com
# Created Time: 2019年09月19日 星期四 21时48分18秒
#########################################################################


####   参数配置 #######################################
HEADER="'User-Agent': 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_10_2) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/40.0.2214.115 Safari/537.36'"

## 环境部署目录 ##
HOME_DIR="./"

## 临时数据存放目录 
indir="${HOME_DIR}/163"

## 结果输出目录
outdir="${HOME_DIR}/out"

## 最大并发任务数量
maxp="20"

## mysql 用户名和密码 ##
user="share"
pass="abcd1234"
## mysql 数据库名称 #
db_name="company_data"

## 加载颜色显示函数 ###
. ${HOME_DIR}/func_color.sh

###     函数定义 ###########################################################################
## 数据下载模块
## 参数： lrb/zcfzb/xjllb ###
download_data()
{
	str_type="$1"
	case "$str_type" in
		"zcfzb")  tbname="share_zcfzb"  ;;
		"lrb")    tbname="share_lrb"    ;;
		"xjllb")  tbname="share_xjllb"  ;;
		*)        echo "无效参数[$str_type]！"  ; exit 1;                ;;
	esac

	[[ -d "$outdir" ]] || { echo "[$outdir] 目录不存在或不可读!!" 1>&2 ; exit 1; }
	[[ -d "$indir" ]] || { echo "[$indir] 目录不存在或不可读!!" 1>&2 ; exit 1; }
	tbname=""
	cnt=0

	awk -F',' '{ print $3 }' ${HOME_DIR}/share_list.csv | while read _id
	do
		ofile="${str_type}_${_id}.csv"
		str_url="http://quotes.money.163.com/service/${str_type}_${_id}.html"
		{
			## 下载资产负债表数据  ##
			curl -H "${HEADER}" -o ${indir}/${ofile} ${str_url}   >/dev/null 2>&1

			## 行列转换 并 添加 股票代码列到第一列 ###
			awk -f ${HOME_DIR}/r2ca.awk ${indir}/${ofile} | iconv -f gbk -t utf-8| awk -v code=${_id} 'BEGIN{ FS=OFS=",";}NR>1 && !/^[\t ]+$|^$|/{ print code,$0 }' > ${outdir}/${ofile}
		} &

		## 控制并发任务数量 ###
		let cnt="$cnt % ${maxp} + 1"
		[[ "$cnt" -eq "$maxp" ]]  && wait
	done

	## 等待剩余不足 ${maxp} 数量并发执行的进程执行完毕 ##
	wait
	sleep 5

	## 合并数据结果文件,然后删除临时文件 ##
	cat $outdir/${str_type}_??????.csv > $outdir/${tbname}.csv  &&	rm -f $outdir/${str_type}_??????.csv 

	## 以股票000001代码为例,获取数据每列标题中文名称 并自动生成对应英文标题名称 ##
	awk -f ${HOME_DIR}/r2ca.awk $indir/${str_type}_000001.csv | awk -v t=${str_type} -v code=${_id} 'BEGIN{ FS=OFS=","; }NR==1{ for(i = 2; i<=NF; i++) if( $i !~ /^[\t ]+$|^$|/) printf("%s_%03d,%s\n", t, i-1 , $i);}'  | iconv -f gbk -t utf-8 > $outdir/${tbname}.head

	### 生成建表语句 ##
	awk -v tbname=${tbname} -f ${HOME_DIR}/gen_table_sql.awk $outdir/${tbname}.head > $outdir/${tbname}.sql 
}

##############################
## 股票信息入库脚本                ###
##############################
import_data()
{
	mysql -u ${user} -p"${pass}" ${db_name} < ${outdir}/share_*.sql 
	mysqlimport --fields-terminated-by=, -u ${user} -p${pass} ${db_name} ${outdir}/share*.head  ${outdir}/share_*.csv
}


#####################
###  主要工作main  ##
#####################

green_line  "数据开始处理,请耐心等待..."

## 下载股票数据 ##
download_data "lrb"   ## 利润表
download_data "zcfzb" ## 资产负债表
download_data "xjllb" ## 现金流量表

##  入库数据 ##
import_data

red_line  "数据处理完毕!"

## END
