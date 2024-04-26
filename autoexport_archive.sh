#!/bin/bash
# 设置程序出错时不再继续执行
set -e

# 加载配置文件（crontab 用的自己的一套环境变量，并没有自动加载系统的配置文件，导致一些命令会找不到，例如：flutter: command not found）
# 不是用crontab可以注释掉
# 更新：为了不影响其他不使用crontab的场景，考虑直接在crontab任务设置中加载.zshrc 文件 如：*/5 * * * * /bin/bash -c 'source /Users/momo/.zshrc; /Users/momo/Documents/GitHub/autoexportArchiveForiOS/autoexport_archive.sh'
# . /Users/momo/.zshrc;

# 环境 develop:开发 test:测试 gray:灰度 product:生产 preproduct:预生产
environment=""
# flutter 项目打包需要使用的分支
flutter_branch=""

# iOS 项目打包需要使用的分支
ios_branch=""

# 打包参数文件的绝对路径（就是下面那些是不常改的参数就放在这个文件，脚本会从这个文件中读取参数）
options_plist=""

# 打包方式 app-store、ad-hoc
ios_method=""

# git仓库用户名(拉代码没问题的话可以不用配置)
git_name=""
# git仓库密码 (拉代码没问题的话可以不用配置)
git_password=""
# apple developer 用户名(不上传app store的话可以不用配置)
apple_developer_name=""
# apple developer 密码 (不上传app store的话可以不用配置)
apple_developer_password=""
# 蒲公英API key
pgyer_api_key=""

# flutter 项目绝对路径
flutter_path=""
# flutter 项目远程仓库地址(只要 http:# 后面的) (拉代码没问题的话可以不用配置)
flutter_git_url=""


# iOS 项目绝对路径
ios_path=""
# iOS 项目远程仓库地址(只要 http:# 后面的) (拉代码没问题的话可以不用配置)
ios_git_url=""

ios_workspace=""
ios_target=""
ios_builld_configurations=""
ios_scheme=""
# iOS项目设置api环境的文件绝对路径
ios_api_file_path=""
# iOS项目设置api环境的字符串
ios_api_string=""
# iOS项目设置api环境的替换字符串
ios_api_replace_string=""

# 归档输出路径
ios_archive_path=""
# ipa输出路径
ios_ipa_export_path=""
# ipa名称
ios_ipa_name=""
# 手动打包输出的adhoc ExportOptions.plist
ios_adhoc_export_options_plist=""
# 手动打包输出的app store ExportOptions.plist
ios_app_store_export_options_plist=""

# 蒲公英所需更新指定的渠道短链接（到对应应用的渠道下面查看）
pgyer_build_channel_shortcut=""
# 自定义版本更新描述
environment_description=""

#提示文案
tips=""


# 👆👆👆👆👆👆👆👆👆👆👆👆👆 上面是需要预先设置的 ❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️

printHelp() {
    echo "iOS自动打包 注意该脚本会放弃所有未提交的本地修改"
    echo "例: /bin/bash autoexport_archive.sh -environment test -flutterBranch dev_stock -iOSBranch developer -optionsPlist /Users/momo/Documents/GitHub/autoexportArchiveForiOS/autoexportArchiveOptions.plist"
    echo "Description:"
    echo "  -environment                  环境 develop:开发 test:测试 gray:灰度 product:生产 preproduct:预生产。该值是 optionsPlist文件中 pgyerBuildChannelShortcuts、environmentDescriptions、iosApiReplaceStrings 所有值的key，要确保一一对应"
    echo "  -flutterBranch                flutter 项目打包需要使用的分支"
    echo "  -iOSBranch                    iOS 项目打包需要使用的分支"
    echo "  -optionsPlist                 打包参数文件的绝对路径（就是下面那些是不常改的参数就放在这个文件，脚本会从这个文件中读取参数）"
    echo "  -help                         帮助文档"
    echo "  ❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️下面是打包参数文件（optionsPlist）key的说明❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️"
    echo "  pgyerApiKey                   蒲公英API key（到蒲公英 个人中心-API令牌 去找）"
    echo "  pgyerBuildChannelShortcuts    所有蒲公英渠道短字符串（到蒲公英 对应应用的 渠道 里设置）的字典，每个值的key要和environment一一对应"
    echo "  environmentDescriptions       所有环境描述的字典,每个值的key要和environment一一对应"
    echo "  iosApiReplaceStrings          iOS项目设置api环境的替换字符串的字典,每个值的key要和environment一一对应"
    echo "  iOSApiFilePath                iOS项目设置api环境的文件绝对路径"
    echo "  iOSApiString                  iOS项目设置api环境的字符串"
    echo "  iOSMethod                     打包方式 app-store、ad-hoc"
    echo "  flutterPath                   flutter 项目绝对路径"
    echo "  iOSPath                       iOS 项目绝对路径"
    echo "  iOSWorkspace                  如：GreeSalesSystem.xcworkspace"
    echo "  iOSTarget                     如：GreeSalesSystem"
    echo "  iOSBuilldConfigurations       如：Release"
    echo "  iOSScheme                     如：GreeSalesSystem_Release"
    echo "  iOSArchivePath                归档输出路径(绝对路径)"
    echo "  iOSipaExportPath              ipa输出路径(绝对路径)"
    echo "  iOSipaName                    ipa名称"
    echo "  iOSAdhocExportOptionsPlist    手动打包输出的adhoc ExportOptions.plist的绝对路径"
    echo "  iOSStoreExportOptionsPlist    手动打包输出的app store ExportOptions.plist的绝对路径"
    echo "  tips                          提示文案"
    exit 1
}

for ((i=1;i<=$#;i++)); do
  if [ "${!i}" = "-environment" ] ; then
    ((i++))
    environment=${!i}
  fi
  if [ "${!i}" = "-flutterBranch" ] ; then
    ((i++))
    flutter_branch=${!i}
  fi
  if [ "${!i}" = "-iOSBranch" ] ; then
    ((i++))
    ios_branch=${!i}
  fi
  if [ "${!i}" = "-optionsPlist" ] ; then
    ((i++))
    options_plist=${!i}
  fi
  if [ "${!i}" = "-help" ] ; then
    printHelp
  fi
done


#git log
flutter_git_logs=""
ios_git_logs=""
# 版本更新描述
update_description=""

# 当前脚本所在的文件路径
currentPath=$(cd `dirname "$0"` && pwd)
iOSArchive="$ios_archive_path/$ios_target.xcarchive"
# 读取options_plist文件的参数
function readeOptionsPlist()
{
      echo "options_plist文件绝对路径： $options_plist"
      checkFileExists $options_plist "options_plist文件绝对路径不存在"
      verifyExecutionResults $?
      echo "====== 开始读取options_plist文件的参数 ======"
      echo "$options_plist 存在"
      pgyer_api_key=$(/usr/libexec/PlistBuddy -c "Print ::pgyerApiKey" $options_plist)
      ios_api_file_path=$(/usr/libexec/PlistBuddy -c "Print ::iOSApiFilePath" $options_plist)
      ios_api_string=$(/usr/libexec/PlistBuddy -c "Print ::iOSApiString" $options_plist)
      ios_method=$(/usr/libexec/PlistBuddy -c "Print ::iOSMethod" $options_plist)
      flutter_path=$(/usr/libexec/PlistBuddy -c "Print ::flutterPath" $options_plist)
      ios_path=$(/usr/libexec/PlistBuddy -c "Print ::iOSPath" $options_plist)
      ios_workspace=$(/usr/libexec/PlistBuddy -c "Print ::iOSWorkspace" $options_plist)
      ios_target=$(/usr/libexec/PlistBuddy -c "Print ::iOSTarget" $options_plist)
      ios_builld_configurations=$(/usr/libexec/PlistBuddy -c "Print ::iOSBuilldConfigurations" $options_plist)
      ios_scheme=$(/usr/libexec/PlistBuddy -c "Print ::iOSScheme" $options_plist)
      ios_archive_path=$(/usr/libexec/PlistBuddy -c "Print ::iOSArchivePath" $options_plist)
      ios_ipa_export_path=$(/usr/libexec/PlistBuddy -c "Print ::iOSipaExportPath" $options_plist)
      ios_ipa_name=$(/usr/libexec/PlistBuddy -c "Print ::iOSipaName" $options_plist)
      ios_adhoc_export_options_plist=$(/usr/libexec/PlistBuddy -c "Print ::iOSAdhocExportOptionsPlist" $options_plist)
      ios_app_store_export_options_plist=$(/usr/libexec/PlistBuddy -c "Print ::iOSStoreExportOptionsPlist" $options_plist)
      pgyer_build_channel_shortcut=$(/usr/libexec/PlistBuddy -c "Print :pgyerBuildChannelShortcuts:$environment" $options_plist)
      environment_description=$(/usr/libexec/PlistBuddy -c "Print :environmentDescriptions:$environment" $options_plist)
      ios_api_replace_string=$(/usr/libexec/PlistBuddy -c "Print :iosApiReplaceStrings:$environment" $options_plist)
      tips=$(/usr/libexec/PlistBuddy -c "Print ::tips" $options_plist)

      echo "  ❗️❗️❗️❗️下面是打包参数文件（optionsPlist）读取到的参数❗️❗️❗️❗️"
      echo "蒲公英API key:$pgyer_api_key"
      echo "iOS项目设置api环境的文件绝对路径:$ios_api_file_path"
      echo "iOS项目设置api环境的字符串:$ios_api_string"
      echo "iOS 打包方式:$ios_method"
      echo "flutter 项目绝对路径:$flutter_path"
      echo "iOS 项目绝对路径:$ios_path"
      echo "iOS workspace:$ios_workspace"
      echo "iOS target:$ios_target"
      echo "iOS builld configurations:$ios_builld_configurations"
      echo "iOS scheme:$ios_scheme"
      echo "归档输出路径(绝对路径)$ios_archive_path"
      echo "ipa输出路径(绝对路径):$ios_ipa_export_path"
      echo "ipa名称:$ios_ipa_name"
      echo "手动打包输出的adhoc ExportOptions.plist的绝对路径:$ios_adhoc_export_options_plist"
      echo "手动打包输出的app store ExportOptions.plist的绝对路径:$ios_app_store_export_options_plist"
      echo "蒲公英渠道短字符串:$pgyer_build_channel_shortcut"
      echo "环境描述:$environment_description"
      echo "iOS项目设置api环境的替换字符串:$ios_api_replace_string"
      echo "提示文案:$tips"
      echo "====== 结束读取options_plist文件的参数 ======"
}
# 校验执行结果
function verifyExecutionResults()
{
    if test $1 -ne 0
    then
     exit 1
    fi
}
# 修改iOS api 环境
function changeiOSApiEnvironment()
{
  if [[ -n "$ios_api_file_path" && -n "$ios_api_string" && -n "$ios_api_replace_string" ]]; then
    local file=$currentPath/change_file.sh
    echo "修改iOS api 环境 $ios_api_file_path $ios_api_string $ios_api_replace_string"
    . "$file" -filePath "$ios_api_file_path" -changeRow 1 -oldContent "$ios_api_string" -newContent "$ios_api_replace_string"
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
        checkFileExists $ios_app_store_export_options_plist "app store ExportOptions.plist绝对路径不存在"
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
}
# 准备工作
function preparation()
{
    # 读取参数
    readeOptionsPlist
    # 校验必要参数
    verifyNecessaryParameters

    # 清空归档文件(没有权限删除就不删了)
    # find $ios_archive_path -type f -name "*.xcarchive" -delete
    # 清空ipa输出文件
    find $ios_ipa_export_path -type f -name "*.ipa" -delete
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
    changeiOSApiEnvironment
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
