# iOS项目自动打包脚本

## mac 终端执行
```shell
# 终端执行脚本命令（要改成自己电脑的路径）
/bin/bash /Users/momo/Documents/GitHub/autoexportArchiveForiOS/autoexport_archive.sh
```
## Crontab 自动执行
## Crontab 定时打包代码示例 (推荐俩个好用的crontab 代码网站：[crontab-generator](https://crontab-generator.org/)、[crontab guru](https://crontab.guru/))
### 设置Crontab任务 
终端执行以下命令
``` shell
# 开始编辑 任务
crontab -e
#然后点击 i 进入编辑状态
# 任务执行反馈到指定邮箱（要改成自己的邮箱）
MAILTO="xxxxxx@163.com"
# 每隔2小时执行一次 (执行的文件要提供绝对路径)（要改成自己电脑的路径）
0 */2 * * * /bin/bash /Users/momo/Documents/GitHub/autoexportArchiveForiOS/autoexport_archive.sh
#编辑完后 点击 ESC 然后 输入 ：wq 结束编辑并保存

#输出所有的定时任务
crontab -l
```
## Crontab 定时打包遇到的问题

### Crontab 任务不执行的问题
[参考链接](https://blog.csdn.net/SnailPace/article/details/126859449)

### flutter: command not found 问题
原因是 crontab 用的自己的一套环境变量，并没有自动加载系统的配置文件，导致一些命令会找不到，例如：flutter: command not found

解决办法：在脚本中 加载配置文件
``` shell
# 也是要绝对路径（要改成自己电脑的路径）
. /Users/momo/.zshrc;
```
[参考链接](https://blog.csdn.net/haveqing/article/details/133637796)

### No signing certificate “iOS Development“ found: No “iOS Development“ signing certificat
原因是 Crontab没有访问用户密钥的权限

解决办法：可以把证书和私钥复制到 钥匙串的 系统-> 我的证书 里，Crontab就可以找到签名证书的密钥了。

[参考链接](https://blog.csdn.net/qq_32873193/article/details/133274449)

### pod install 时报错
``` shell
# 报错大致如下
   [33mWARNING: CocoaPods requires your terminal to be using UTF-8 encoding.
   Consider adding the following to ~/.profile:

   export LANG=en_US.UTF-8
   [0m
/usr/local/Cellar/ruby/3.2.2_1/lib/ruby/3.2.0/unicode_normalize/normalize.rb:141:in `normalize': Unicode Normalization not appropriate for ASCII-8BIT (Encoding::CompatibilityError)
   from /usr/local/Cellar/cocoapods/1.12.1/libexec/gems/cocoapods-1.12.1/lib/cocoapods/config.rb:166:in `unicode_normalize'
   from /usr/local/Cellar/cocoapods/1.12.1/libexec/gems/cocoapods-1.12.1/lib/cocoapods/config.rb:166:in `installation_root'
```

Consider adding the following to ~/.profile:

export LANG=en_US.UTF-8

👆上面这两句就是解决办法， 但是发现 在.profile文件中加入 export LANG=en_US.UTF-8 不起作用，最后改了.zshrc文件。
改完 .zshrc 后终端运行一下代码
``` shell
source .zshrc
# 查看是否已正确配置
echo $LANG
```
[参考链接1](https://www.coder.work/article/7771908#google_vignette)

[参考链接2](https://www.jianshu.com/p/3241de892e4d)