# iOS项目自动打包脚本

## mac 终端执行
```shell
# 终端执行脚本命令（要改成自己电脑的路径）
/bin/bash /Users/momo/Documents/GitHub/autoexportArchiveForiOS/autoexport_archive.sh
# 会加载 .zshrc 文件，然后再运行脚本
/bin/bash -c 'source /Users/momo/.zshrc; /Users/momo/Documents/GitHub/autoexportArchiveForiOS/autoexport_archive.sh'
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
### 通过文件批量添加Crontab 任务
1、首先，创建一个文本文件（例如 crontab_jobs.txt），在这个文件中列出你想要添加的所有crontab任务，每个任务占一行。
2、打开终端，使用 crontab crontab_jobs.txt 命令来导入你的crontab任务。
``` shell
# 该命令会覆盖当前的 crontab 任务
crontab crontab_jobs.txt
```
#### 如果想要保留当前的 crontab 任务，并添加新的任务， 可以使用以下方法：
``` shell
# 1、将当前的 crontab 任务导出到current_jobs.txt文件中
# 2、将新的任务添加到current_jobs.txt文件的末尾
# 3、运行 crontab current_jobs.txt 命令导入所有任务
crontab -l > current_jobs.txt

crontab current_jobs.txt
```

## Crontab 定时打包遇到的问题

### Crontab 任务不执行的问题
[参考链接](https://blog.csdn.net/SnailPace/article/details/126859449)

### flutter: command not found 问题
原因是 crontab 用的自己的一套环境变量，并没有自动加载系统的配置文件，导致一些命令会找不到，例如：flutter: command not found

~~解决办法：在脚本中 加载配置文件~~
``` shell
# 也是要绝对路径（要改成自己电脑的路径）
. /Users/momo/.zshrc;
```
#### 优化：为了不影响其他不使用crontab的场景，考虑直接在crontab任务设置中加载.zshrc 文件，而不是像上面那样直接在脚本中加载配置文件
``` shell
0 */2 * * * /bin/bash -c 'source /Users/momo/.zshrc; /Users/momo/Documents/GitHub/autoexportArchiveForiOS/autoexport_archive.sh'
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