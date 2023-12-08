#!/bin/bash
dateString=`date +"%Y/%m/%d %H:%M:%S"`
log="执行时间 $dateString"
echo $log >> /Users/momo/Desktop/crontab_test_log/logs.txt
