# autoexportArchiveForiOS
iOS项目自动打包脚本

# Crontab 自动执行
```shell
# 以下暂未验证，可以尝试
# 任务执行失败反馈到指定邮箱
MAILTO="timer_sevenwang@163.com"
# 每隔2小时执行一次
0 */2 * * * /bin/bash /Users/momo/Documents/GitHub/autoexportArchiveForiOS/autoexport_archive.sh
```