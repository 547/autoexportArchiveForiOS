#!/bin/bash
# 设置程序出错时不再继续执行
set -e
# git仓库用户名(拉代码没问题的话可以不用配置)
git_name=""
# git仓库密码 (拉代码没问题的话可以不用配置)
git_passward=""
#/ 蒲公英API key
pgyer_api_key="c6c5e3109ff59647d57f0c6c5944bb5f"
# 蒲公英所需更新指定的渠道短链接（到对应应用的渠道下面查看）
pgyer_build_channel_shortcut="AutomaticWorkflow"
# flutter 项目绝对路径
flutter_path="/Users/momo/Documents/AutomaticWorkflow/flutter-pin-module"
# flutter 项目远程仓库地址(只要 http:# 后面的) (拉代码没问题的话可以不用配置)
flutter_git_url="git.upms.gree.com/dept5-front/flutter-pin-module.git"
# flutter 项目打包需要使用的分支
flutter_branch="release_23_12_07"
# iOS 项目绝对路径
ios_path="/Users/momo/Documents/AutomaticWorkflow/ios-pin/salesSystem"
# iOS 项目远程仓库地址(只要 http:# 后面的) (拉代码没问题的话可以不用配置)
ios_git_url="git.upms.gree.com/dept5-front/ios-pin.git"
# iOS 项目打包需要使用的分支
ios_branch="product_1.0.61"
ios_workspace="GreeSalesSystem.xcworkspace"
ios_target="GreeSalesSystem"
ios_builld_configurations="Release"
ios_scheme="GreeSalesSystem_Release"
# 打包方式 app-store、ad-hoc
ios_method="ad-hoc"
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
# 版本更新描述
update_description="自动化测试"


# 👆👆👆👆👆👆👆👆👆👆👆👆👆 上面是需要预先设置的 ❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️❗️

# 当前脚本所在的文件路径
currentPath=$(cd `dirname "$0"` && pwd)
iOSArchive="$ios_archive_path/$ios_target.xcarchive"
# 校验字符串是否为空
function checkStringValid()
{
    if [ -z $1 ]; then
    echo $2
    return 1
    else
        return 0
    fi
}
# 校验文件是否存在
function checkFileExists()
{
    if [ ! -f $1 ]; then
    echo $2
    return 1
    else
        return 0
    fi
}
# 校验路径是否存在
function checkPathExists()
{
    if [ ! -d $1 ]; then
    echo $2
    return 1
    else
        return 0
    fi
}
# 校验执行结果
function verifyExecutionResults()
{
    if [ $1 -ne 0 ];then
     exit 1
    fi
}
# 校验必要参数
function verifyNecessaryParameters()
{
    # checkStringValid $git_name "git仓库用户名不能为空"
    # verifyExecutionResults $?
    # checkStringValid $git_passward "git仓库密码不能为空"
    # verifyExecutionResults $?
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

    # 清空归档文件(没有权限删除就不删了)
    # find $ios_archive_path -type f -name "*.xcarchive" -delete
    # 清空ipa输出文件
    find $ios_ipa_export_path -type f -name "*.ipa" -delete

}
function releaseFlutterProject() {
    echo "开始执行flutter项目任务"
    cd $flutter_path
    # http://用户名:密码@host:/path/to/repository
    # 拉代码没问题的话可以不用跑这俩条命令
    # flutterGitUrl="http://$git_name:$git_passward@$flutter_git_url"
    # git remote set-url origin $flutterGitUrl
    git checkout $flutter_branch
    git pull
    # flutter clean
    flutter pub get
    flutter build ios --release --no-tree-shake-icons
    verifyExecutionResults $?
    echo "flutter项目任务执行结束"
}
function releaseiOSProject() {
    echo "开始执行iOS项目任务"
    cd $ios_path
    # 拉代码没问题的话可以不用跑这俩条命令
    # iOSGitUrl="http://$git_name:$git_passward@$ios_git_url"
    # git remote set-url origin $iOSGitUrl
    git checkout $ios_branch
    git pull
    pod install
    echo "开始打包"
    xcodebuild clean -scheme $ios_scheme
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
    uploadFile=$currentPath/pgyer_upload.sh
    echo "$ipaFile 上传到蒲公英脚本文件 $uploadFile"
    . $uploadFile -k $pgyer_api_key -d $update_description -c $pgyer_build_channel_shortcut $ipaFile
    echo "上传蒲公英任务执行完毕"
}
verifyNecessaryParameters
releaseFlutterProject
releaseiOSProject
uploadPgyer