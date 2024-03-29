#!/bin/bash
# 设置程序出错时不再继续执行
set -e

printHelp() {
    echo "修改指定文件的内容需要传入 文件的绝对路径 原内容 新内容"
    echo "例如: /bin/bash change_file.sh -f /Users/momo/Documents/GitHub/autoexportArchiveForiOS/test.txt -o "const bool SINGLE_COMPILE = true" -n "const bool SINGLE_COMPILE = false" -r 1"
    echo "Description:"
    echo "  -f filePath                      文件的绝对路径"
    echo "  -o oldContent                    原内容"
    echo "  -n newContent                    新内容"
    echo "  -r changeRow                     是否修改整行的内容 1： 是"
    echo "  -h help                          帮助文档"
    exit 1
}
while getopts 'f:o:n:r:h' OPT; do
    case $OPT in
        f) filePath="$OPTARG";;
        o) oldContent="$OPTARG";;
        n) newContent="$OPTARG";;
        r) changeRow="$OPTARG";;
        ?) printHelp;;
    esac
done


# sed编辑命令：【sed -i "s/a/b/g" test.txt】
 
# 报错：sed: 1: "test.txt": undefined label 'est.txt'
 
# 解决方案：增加一个备份的追加名【sed -i ".bak" "s/a/b/g" test.txt】
 
# 原因：mac强制要求备份，否则报错
# 当然可以不使用其他备份名字，只是用 ""，就可以只保留一份
# sed -i "" "s/a/b/g" test.txt
if [ "$changeRow" -eq 1 ]
then
    # 获取包含 oldContent 的行号
    line_number=$(grep -n "$oldContent" $filePath | cut -d: -f1)
    # 使用 sed 替换指定行的内容
    sed -i "" "${line_number}s/.*/${newContent}/" $filePath
else
    # 使用sed命令替换文件中的文本
    sed -i "" "s/${oldContent}/${newContent}/g" $filePath
fi







echo "文件内容已经成功修改！ "