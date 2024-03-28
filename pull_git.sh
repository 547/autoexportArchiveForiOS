#!/bin/bash
# 设置程序出错时不再继续执行
set -e


printHelp() {
    echo "拉取git仓库代码"
    echo "例如: /bin/bash pull_git.sh -filePath /Users/momo/Documents/GitHub/autoexportArchiveForiOS -branch main -httpsProxy http://127.0.0.1:7890 -httpProxy http://127.0.0.1:7890 -allProxy socks5://127.0.0.1:7890"
    echo "Description:"
    echo "  -filePath                      文件的绝对路径"
    echo "  -branch                        分支名称"
    echo "  -httpsProxy                    https代理"
    echo "  -httpProxy                    http代理"
    echo "  -allProxy                    所有代理"
    echo "  -help                          帮助文档"
    exit 1
}

for ((i=1;i<=$#;i++)); do
  if [ ${!i} = "-filePath" ] ; then
    ((i++))
    filePath=${!i}
  fi
  if [ ${!i} = "-branch" ] ; then
    ((i++))
    branch=${!i}
  fi
  if [ ${!i} = "-httpsProxy" ] ; then
    ((i++))
    httpsProxy=${!i}
  fi
  if [ ${!i} = "-httpProxy" ] ; then
    ((i++))
    httpProxy=${!i}
  fi
  if [ ${!i} = "-allProxy" ] ; then
    ((i++))
    allProxy=${!i}
  fi
  if [ ${!i} = "-help" ] ; then
    printHelp
  fi
done
echo "参数 $filePath $branch $httpsProxy $httpProxy $allProxy"


# 校验字符串是否为空
function checkStringValid()
{
    if test -z $1
    then
    echo $2
    return 1
    else
        return 0
    fi
}
# 校验路径是否存在
function checkPathExists()
{
    if test -d $1 
    then
        return 0
    else
        echo $2
        return 1       
    fi
}
# 校验执行结果
function verifyExecutionResults()
{
    if test $1 -ne 0
    then
     exit 1
    fi
}
# 切换分支
function checkoutBranch()
{
    local branchName=`git branch --show-current`
    echo "当前分支：$branchName"
    if test "$branchName" != "$1"
    then
        # 获取远程仓库的更新 (解决切换到本地没有的远程分支时报错问题)
        git fetch
        git checkout $1
        verifyExecutionResults $?
        echo "切到了$1分支"
    fi
}

# 拉取远程仓库的代码
function gitPull()
{
    # 更新远程引用
    git remote update

    # 检查本地分支是否落后于远程分支
    # 获取本地分支落后于远程分支的提交数
    local commitCount=$(git rev-list --count $branch..$branch@{upstream})
    echo "本地分支落后于远程分支的提交数为：$commitCount"
    if [ $commitCount -gt 0 ]
    then
        echo "本地仓库落后于远程仓库，正在拉取代码..."
        git pull
    else
        echo "本地仓库与远程仓库同步，无需拉取代码。"
    fi
}

# 设置代理
function setProxy()
{
   if test -n "$httpsProxy" && test -n "$httpProxy" && test -n "$allProxy"
   then
        echo "设置代理"
        export https_proxy=$httpsProxy http_proxy=$httpProxy all_proxy=$allProxy
   fi
}


# 加载配置文件（crontab 用的自己的一套环境变量，并没有自动加载系统的配置文件，导致一些命令会找不到，例如：flutter: command not found）
# 不是用crontab可以注释掉
. /Users/momo/.zshrc;

checkPathExists $filePath "git仓库绝对路径不存在"
checkStringValid $branch "分支名称不能为空"
cd $filePath

# 设置代理
setProxy

checkoutBranch "$branch"

gitPull
