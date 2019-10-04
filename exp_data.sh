#!/bin/bash
#########################################################################
# File Name: exp_data.sh
# Author: zwker
# mail: xiaoyu0720@gmail.com
# Created Time: 2019年09月25日 星期三 16时57分11秒
#########################################################################

mysql --column-names -u tushare -p'abcd1234' tushare <<END

SELECT
    a._id '股票代码',
    sl.name '公司名称',
    sl.industry '行业',
    sl.list_date '上市时间',
    substr(a.report_date,1,4) '财报时间',
    ROUND(  b.lrb_041 / a.zcfzb_105 * 100 ,   1) '获利-股东权益报酬率RoE %',
    round(zcfzb_001/zcfzb_052 *100,1) '现金与约当现金比率%',
    round(lrb_040/100,0)  '获利-税后净利(百万元)',
	ROUND(xj.xjllb_025/100) '营业活动现金流量(百万元)',
	ROUND(xj.xjllb_040/100) '投资活动现金流量(百万元)',
    zcfzb_052/100 '资产总计(百万元)',
    round( (b.lrb_002 - b.lrb_009)/b.lrb_002 * 100 , 1) '获利-营业毛利率%',
    round( (b.lrb_002 - b.lrb_009-b.lrb_020-b.lrb_021-b.lrb_022-b.lrb_023-b.lrb_024)/b.lrb_002 * 100 , 1) '获利-营业利益率%'  ,
    round(round( (b.lrb_002 - b.lrb_009-b.lrb_020-b.lrb_021-b.lrb_022-b.lrb_023-b.lrb_024)/b.lrb_002 * 100 , 1) / round( (b.lrb_002 - b.lrb_009)/b.lrb_002 * 100 , 1)  * 100,1) '获利-经营安全边际率%',
    round((1 - zcfzb_107/zcfzb_052) *100,1)  '财务结构-负债占资产比率%',
    round((zcfzb_092+zcfzb_107)/(zcfzb_037) *100,1)  '财务结构-长期资金占不动产/厂房及设备比率%',
    round(zcfzb_007/zcfzb_052 *100,1) '应收账款%',
    round(zcfzb_020/zcfzb_052 *100,1) '存货%',
    round(zcfzb_025/zcfzb_052 *100,1)  '流动资产%',
    round(zcfzb_037/zcfzb_052 *100,1)  '固定资产%',
    round(zcfzb_060/zcfzb_052 *100,1) '应付账款%',
    round(zcfzb_084/zcfzb_052 *100,1)  '流动负债%',
    round(zcfzb_092/zcfzb_052 *100,1)  '长期负债%',
    round(zcfzb_107/zcfzb_052 *100,1)  '股东权益%',
    round((zcfzb_025/zcfzb_084) *100,1)  '偿债-流动比率%',
    round(((zcfzb_025-zcfzb_020)/zcfzb_084) *100,1)  '偿债-速动比率%',
    ROUND(  b.lrb_041 / a.zcfzb_052 * 100 ,   1) '获利-总资产报酬率RoA %',
    ROUND(  b.lrb_040 / b.lrb_002 * 100 ,   1)  '获利-净利率%',
    ROUND(  b.lrb_044 ,   1) '获利-每股盈余(元)',
    round(xj.xjllb_025/zcfzb_084 * 100 , 1 ) '现金流量比率(%)',
    ROUND((xj.xjllb_033-xj.xjllb_028)/100) '存货增加额(百万元)',
    ROUND( (xj.xjllb_025-xj.xjllb_048) / (zcfzb_052-zcfzb_084) * 100, 1) '现金再投资比率%'
FROM
    share_zcfzb a, share_lrb b , share_xjllb AS xj, share_list sl
WHERE
    a.report_date like '2018-12-__'
    AND a._id = sl.symbol
    and a._id = b._id
    and a._id = xj._id
    and a.report_date = b.report_date
    and b.report_date = xj.report_date

# INTO outfile '/tmp/tushare.csv' FIELDS terminated by '\,'
; 

quit

END
