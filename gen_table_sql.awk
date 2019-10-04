#!/bin/awk -f
BEGIN{
	FS=","
	if( tbname )
		printf("drop table if exist %s; create table tushare.%s \n(\n\t_id varchar(12),\n\treport_date varchar(12),\n", tbname, tbname);
	else {
		printf("table name not set [-v tbname=xxxx]!\n") > "/dev/stderr" 
		exit 1
	}

}
$1!~/^$/{
	print "\t" $1 " float not null COMMENT '"$2 "'," 
}END{
	printf("\tPRIMARY KEY(`_id`,`report_date`)\n) ENGINE = InnoDB;\n");
}

