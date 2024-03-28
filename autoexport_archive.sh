#!/bin/bash
# 设置程序出错时不再继续执行
set -e

# 加载配置文件（crontab 用的自己的一套环境变量，并没有自动加载系统的配置文件，导致一些命令会找不到，例如：flutter: command not found）
# 不是用crontab可以注释掉
# 更新：为了不影响其他不使用crontab的场景，考虑直接在crontab任务设置中加载.zshrc 文件 如：*/5 * * * * /bin/bash -c 'source /Users/momo/.zshrc; /Users/momo/Documents/GitHub/autoexportArchiveForiOS/autoexport_archive.sh'
# . /Users/momo/.zshrc;
# 环境 1:开发 2:测试 3:灰度 4:生产 5:预生产
environment=4

# flutter 项目打包需要使用的分支
flutter_branch="release_24_03_28"

# iOS 项目打包需要使用的分支
ios_branch="release_1.3.1"

# 打包方式 app-store、ad-hoc
ios_method="ad-hoc"

# git仓库用户名(拉代码没问题的话可以不用配置)
git_name=""
# git仓库密码 (拉代码没问题的话可以不用配置)
git_password=""
# apple developer 用户名(不上传app store的话可以不用配置)
apple_developer_name=""
# apple developer 密码 (不上传app store的话可以不用配置)
apple_developer_password=""
#/ 蒲公英API key
pgyer_api_key="c6c5e3109ff59647d57f0c6c5944bb5f"

# flutter 项目绝对路径
flutter_path="/Users/momo/Documents/AutomaticWorkflow/flutter-pin-module"
# flutter 项目远程仓库地址(只要 http:# 后面的) (拉代码没问题的话可以不用配置)
flutter_git_url="git.upms.gree.com/dept5-front/flutter-pin-module.git"


# iOS 项目绝对路径
ios_path="/Users/momo/Documents/AutomaticWorkflow/ios-pin/salesSystem"
# iOS 项目远程仓库地址(只要 http:# 后面的) (拉代码没问题的话可以不用配置)
ios_git_url="git.upms.gree.com/dept5-front/ios-pin.git"

ios_workspace="GreeSalesSystem.xcworkspace"
ios_target="GreeSalesSystem"
ios_builld_configurations="Release"
ios_scheme="GreeSalesSystem_Release"

# 归档输出路径
ios_archive_path="/Users/momo/Documents/AutomaticWorkflow/output/GreeSalesSystem"
# ipa输出路径
ios_ipa_export_path="/Users/momo/Documents/AutomaticWorkflow/output/GreeSalesSystem"
# ipa名称
ios_ipa_name="格力动销"
# 手动打包输出的adhoc ExportOptions.plist
ios_adhoc_export_options_plist="/Users/momo/Documents/AutomaticWorkflow/plists/GreeSalesSystem/AdhocExportOptions.plist"
# 手动打包输出的app store ExportOptions.plist
ios_app_store_export_options_plist="/Users/momo/Documents/AutomaticWorkflow/plists/GreeSalesSystem/AppStoreExportOptions.plist"

#提示文案
tips="❗️❗️❗️有渠道链接请务必使用渠道链接下载app❗️❗️❗️"


# 👆👆👆👆👆👆👆👆👆👆👆👆👆 上面是需要预先设置的 ❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️

printHelp() {
    echo "iOS自动打包"
    echo "例如: /bin/bash autoexport_archive.sh -environment 2 -flutterBranch dev_stock -iOSBranch developer -iOSMethod ad-hoc -flutterPath /Users/momo/Documents/AutomaticWorkflow/flutter-pin-module -iOSPath /Users/momo/Documents/AutomaticWorkflow/ios-pin/salesSystem -iOSWorkspace GreeSalesSystem.xcworkspace -iOSTarget GreeSalesSystem -iOSBuilldConfigurations Release -iOSScheme GreeSalesSystem_Release -iOSArchivePath /Users/momo/Documents/AutomaticWorkflow/output/GreeSalesSystem -iOSipaExportPath /Users/momo/Documents/AutomaticWorkflow/output/GreeSalesSystem -iOSipaName 格力动销 -iOSAdhocExportOptionsPlist /Users/momo/Documents/AutomaticWorkflow/plists/GreeSalesSystem/AdhocExportOptions.plist -iOSStoreExportOptionsPlist /Users/momo/Documents/AutomaticWorkflow/plists/GreeSalesSystem/AppStoreExportOptions.plist"
    echo "Description:"
    echo "  -environment                  环境 1:开发 2:测试 3:灰度 4:生产 5:预生产 和蒲公英渠道直接相关,注意项目的环境要和该值一致"
    echo "  -flutterBranch                flutter 项目打包需要使用的分支"
    echo "  -iOSBranch                    iOS 项目打包需要使用的分支"
    echo "  -iOSMethod                    打包方式 app-store、ad-hoc"
    echo "  -flutterPath                  flutter 项目绝对路径"
    echo "  -iOSPath                      iOS 项目绝对路径"
    echo "  -iOSWorkspace                 如：GreeSalesSystem.xcworkspace"
    echo "  -iOSTarget                    如：GreeSalesSystem"
    echo "  -iOSBuilldConfigurations      如：Release"
    echo "  -iOSScheme                    如：GreeSalesSystem_Release"
    echo "  -iOSArchivePath               归档输出路径(绝对路径)"
    echo "  -iOSipaExportPath             ipa输出路径(绝对路径)"
    echo "  -iOSipaName                   ipa名称"
    echo "  -iOSAdhocExportOptionsPlist   手动打包输出的adhoc ExportOptions.plist的绝对路径"
    echo "  -iOSStoreExportOptionsPlist   手动打包输出的app store ExportOptions.plist的绝对路径"
    echo "  -tips                         提示文案"
    echo "  -help                         帮助文档"
    exit 1
}

for ((i=1;i<=$#;i++)); do
  if [ ${!i} = "-environment" ] ; then
    ((i++))
    environment=${!i}
  fi
  if [ ${!i} = "-flutterBranch" ] ; then
    ((i++))
    flutter_branch=${!i}
  fi
  if [ ${!i} = "-iOSBranch" ] ; then
    ((i++))
    ios_branch=${!i}
  fi
  if [ ${!i} = "-iOSMethod" ] ; then
    ((i++))
    ios_method=${!i}
  fi
  if [ ${!i} = "-flutterPath" ] ; then
    ((i++))
    flutter_path=${!i}
  fi
    if [ ${!i} = "-iOSPath" ] ; then
    ((i++))
    ios_path=${!i}
  fi
  if [ ${!i} = "-iOSWorkspace" ] ; then
    ((i++))
    ios_workspace=${!i}
  fi
  if [ ${!i} = "-iOSTarget" ] ; then
    ((i++))
    ios_target=${!i}
  fi
    if [ ${!i} = "-iOSBuilldConfigurations" ] ; then
    ((i++))
    ios_builld_configurations=${!i}
  fi
  if [ ${!i} = "-iOSScheme" ] ; then
    ((i++))
    ios_scheme=${!i}
  fi
  if [ ${!i} = "-iOSArchivePath" ] ; then
    ((i++))
    ios_archive_path=${!i}
  fi
    if [ ${!i} = "-iOSipaExportPath" ] ; then
    ((i++))
    ios_ipa_export_path=${!i}
  fi
  if [ ${!i} = "-iOSipaName" ] ; then
    ((i++))
    ios_ipa_name=${!i}
  fi
  if [ ${!i} = "-iOSAdhocExportOptionsPlist" ] ; then
    ((i++))
    ios_adhoc_export_options_plist=${!i}
  fi
  if [ ${!i} = "-iOSStoreExportOptionsPlist" ] ; then
    ((i++))
    ios_app_store_export_options_plist=${!i}
  fi
  if [ ${!i} = "-tips" ] ; then
    ((i++))
    tips=${!i}
  fi
  if [ ${!i} = "-help" ] ; then
    printHelp
  fi
done

# 蒲公英所需更新指定的渠道短链接（到对应应用的渠道下面查看）
pgyer_build_channel_shortcut=""
# 自定义版本更新描述
environment_description=""
#git log
flutter_git_logs=""
ios_git_logs=""
# 版本更新描述
update_description=""

# 当前脚本所在的文件路径
currentPath=$(cd `dirname "$0"` && pwd)
iOSArchive="$ios_archive_path/$ios_target.xcarchive"
# 根据环境更新相关的信息
function updateEnvironmentInfo()
{
    case $environment in
        1) 
        pgyer_build_channel_shortcut="iOSDev"
        environment_description="开发环境"
        ;;
        2) 
        pgyer_build_channel_shortcut="iOSTest_gree"
        environment_description="测试环境"
        ;;
        3) 
        pgyer_build_channel_shortcut="iOSCanary"
        environment_description="灰度环境"
        ;;
        4)
        pgyer_build_channel_shortcut="iOSProduct"
        environment_description="生产环境"
        ;;
        5)
        pgyer_build_channel_shortcut="iOSPreproduct"
        environment_description="预生产环境"
        ;;
        *)
        pgyer_build_channel_shortcut="AutomaticWorkflow"
        environment_description="自动化测试"
        ;;
    esac
    echo $pgyer_build_channel_shortcut
    echo $environment_description
}
# 校验执行结果
function verifyExecutionResults()
{
    if test $1 -ne 0
    then
     exit 1
    fi
}
# 拉取远程仓库的代码
function pullGit()
{
    echo "参数 $1 $2"
    local file=$currentPath/pull_git.sh
    echo "拉取远程仓库的代码的脚本文件 $file"
    . "$file" -filePath "$1" -branch "$2"
}
# 获取 git logs
function getGitLogs()
{   
    local branch=$(git branch --show-current)
    local logs=$(git log --no-merges $branch -5 --pretty="format:\n* %s [%ad]" --date=format:"%Y/%m/%d %H:%M:%S")
    local result="$1当前分支：$branch"
    # 在 Bash 中，IFS（Internal Field Separator，内部字段分隔符）是一个特殊的变量，它决定了 Bash 如何识别单词和字段的边界12。默认情况下，IFS 的值是一个包含空格、制表符和换行符的三字符字符串。
    # 将 IFS 设置为换行符，这样 for 循环就会在每个换行符处分割 logs 变量，而不是在空格处分割。这样，即使提交日志中包含链接，换行符也能正常工作。
    # 保存旧的 IFS 值
    oldIFS=$IFS
    # 设置新的 IFS 值
    IFS=$'\n'
    for element in $logs
    do
        result="${result}${element}"
    done
    # 恢复旧的 IFS 值
    IFS=$oldIFS

    echo "$result"

    if test "$1" == "flutter" 
    then
        flutter_git_logs="$result"
    elif test "$1" == "iOS"
    then
        ios_git_logs="$result"
    fi
}

# 拼接更新文案
function getUpdateDescription()
{
    # 保存旧的 IFS 值
    oldIFS=$IFS
    # 设置新的 IFS 值
    IFS=$'\n'
    local result="$environment_description\n$tips\n$ios_git_logs\n$flutter_git_logs"
    # 恢复旧的 IFS 值
    IFS=$oldIFS
    echo "$result"
    update_description="$result"
}

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
# 校验文件是否存在
function checkFileExists()
{
    if test -f $1 
    then
        return 0
    else
        echo $2
        return 1
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

# 校验必要参数
function verifyNecessaryParameters()
{
    # checkStringValid $git_name "git仓库用户名不能为空"
    # verifyExecutionResults $?
    # checkStringValid $git_password "git仓库密码不能为空"
    # verifyExecutionResults $?
    if test $ios_method = "app-store"
    then
        checkStringValid $apple_developer_name "apple developer用户名不能为空"
        verifyExecutionResults $?
        checkStringValid $apple_developer_password "apple developer密码不能为空"
        verifyExecutionResults $?
    fi
    checkStringValid $pgyer_api_key "蒲公英API key不能为空"
    verifyExecutionResults $?
    checkPathExists $flutter_path "flutter 项目绝对路径不存在"
    verifyExecutionResults $?
    # checkStringValid $flutter_git_url "flutter 项目远程仓库地址不能为空"
    # verifyExecutionResults $?
    checkStringValid $flutter_branch "flutter 项目打包需要使用的分支不能为空"
    verifyExecutionResults $?
    checkPathExists $ios_path "iOS 项目绝对路径不存在"
    verifyExecutionResults $?
    # checkStringValid $ios_git_url "iOS 项目远程仓库地址不能为空"
    # verifyExecutionResults $?
    checkStringValid $ios_branch "iOS 项目打包需要使用的分支不能为空"
    verifyExecutionResults $?
    checkStringValid $ios_workspace "ios_workspace不能为空"
    verifyExecutionResults $?
    checkStringValid $ios_target "ios_target不能为空"
    verifyExecutionResults $?

    checkStringValid $ios_builld_configurations "ios_builld_configurations不能为空"
    verifyExecutionResults $?
    checkStringValid $ios_scheme "ios_scheme不能为空"
    verifyExecutionResults $?
    checkStringValid $ios_method "ios_method不能为空"
    verifyExecutionResults $?
    checkStringValid $ios_ipa_name "ios_ipa_name不能为空"
    verifyExecutionResults $?

    checkPathExists $ios_archive_path "归档输出绝对路径不存在"
    verifyExecutionResults $?
    checkPathExists $ios_ipa_export_path "ipa输出绝对路径不存在"
    verifyExecutionResults $?
    checkFileExists $ios_adhoc_export_options_plist "adhoc ExportOptions.plist绝对路径不存在"
    verifyExecutionResults $?
    checkFileExists $ios_app_store_export_options_plist "app store ExportOptions.plist绝对路径不存在"
    verifyExecutionResults $?
}
# 准备工作
function preparation()
{
    # 获取参数
    # getParameters
    # 校验必要参数
    verifyNecessaryParameters

    # 清空归档文件(没有权限删除就不删了)
    # find $ios_archive_path -type f -name "*.xcarchive" -delete
    # 清空ipa输出文件
    find $ios_ipa_export_path -type f -name "*.ipa" -delete
    
    # 更新环境相关的信息
    updateEnvironmentInfo
}
function releaseFlutterProject() {
    echo "开始执行flutter项目任务"
    pullGit "$flutter_path" "$flutter_branch"
    verifyExecutionResults $?
    getGitLogs "flutter"
    # flutter clean
    flutter pub get
    flutter build ios --release --no-tree-shake-icons
    verifyExecutionResults $?
    echo "flutter项目任务执行结束"
}
function releaseiOSProject() {
    echo "开始执行iOS项目任务"
    pullGit "$ios_path" "$ios_branch"
    verifyExecutionResults $?
    getGitLogs "iOS"
    pod install
    echo "开始打包"
    xcodebuild clean -scheme $ios_scheme -configuration $ios_builld_configurations -alltargets
    echo "clean 成功"
    xcodebuild archive -workspace $ios_workspace -scheme $ios_scheme -configuration $ios_builld_configurations -destination generic/platform=ios -archivePath $iOSArchive
    verifyExecutionResults $?
    # .xcarchive是个文件夹不是文件
    checkPathExists $iOSArchive "archive 失败"
    verifyExecutionResults $?
    echo "archive 成功"
    iOSExportOptionsPlist=$ios_adhoc_export_options_plist
    if test $ios_method = "app-store"
    then
        iOSExportOptionsPlist=$ios_app_store_export_options_plist
    fi
    echo "iOS export options plist: $iOSExportOptionsPlist"
    xcodebuild -exportArchive -archivePath $iOSArchive -exportOptionsPlist $iOSExportOptionsPlist -exportPath $ios_ipa_export_path
    ipaFile="$ios_ipa_export_path/$ios_ipa_name.ipa"
    checkFileExists $ipaFile "打包 失败"
    verifyExecutionResults $?
    echo "打包 成功"
    echo "ipa 输出路径：$ipaFile"
}
# 上传到蒲公英
function uploadPgyer()
{
    echo "开始上传蒲公英"
    local file=$currentPath/pgyer_upload.sh
    echo "$ipaFile 上传到蒲公英脚本文件 $file"
    getUpdateDescription
    . "$file" -k "$pgyer_api_key" -d "$update_description" -c "$pgyer_build_channel_shortcut" "$ipaFile"
    echo "上传蒲公英任务执行完毕"
}
# 上传到App Store
function uploadAppStore()
{
    echo "开始上传App Store"
          #验证APP
    xcrun altool --validate-app \
    -f "$ipaFile" \
    -t iOS \
    -u "$apple_developer_name" \
    -p "$apple_developer_password" \
    --output-format xml        

    #上传APP
    xcrun altool --upload-app \
    -f "$ipaFile" \
    -t iOS \
    -u "$apple_developer_name" \
    -p "$apple_developer_password" \
    --output-format xml

    echo "上传App Store任务执行完毕"
}
# 上传ipa
function uploadIpa()
{
    if test "$ios_method" = "ad-hoc" 
    then
        uploadPgyer
    elif test "$ios_method" = "app-store"
    then
        uploadAppStore
    fi
}

preparation
releaseFlutterProject
releaseiOSProject
uploadIpa
