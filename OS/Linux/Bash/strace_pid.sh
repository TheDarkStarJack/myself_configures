#!/bin/bash
#===============================================================================
#
#          FILE: strace_pid
#
#         USAGE: strace_pid <pid> [args2]
#
#   DESCRIPTION: 用于 strace pg 进程的信息
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: wxj (DarkStar), 2403220952@qq.com
#  ORGANIZATION:.
#       CREATED: 2024-09-03 10:02:54
#       LASTMOD:
#      REVISION:  ---
#===============================================================================

#set -o nounset # Treat unset variables as an error

LogDir="/Postgres/stracelog"
LogFile="${LogDir}/${1}_read.log"

if test ! -d "$LogDir"; then
	echo "$LogDir is not exists."
	mkdir -pv "$LogDir"
fi

nohup strace -tt -Y -f -r -o "$LogFile" -p "$1" 1>/dev/null 2>"${LogDir}/error.log" &
echo "process info :" && ps -ef | grep "$LogFile" | grep -v grep

{
	echo "#This file contains the PID information of the Strace process"
	# 在同一时间 pid 大概率不会出现复用的情况，所以这里就不在判断 pid 是否复用的情况了
	#ps -ef | grep "$LogFile" | grep -v grep | awk -v sp="$1" '{ if ($2 -eq sp) {print "kill -15 " $2 ;} else {print "please check error.log,no pid info." }}'
	local pmark=$(ps -ef | grep "$LogFile" | grep -v grep | awk '{print $2}') 
	if test -n "$pmark" ;then 
		echo "#please check error.log,no pid info." 
	else 
		echo "kill -15 " $2  
		echo "rm -f ${LogDir}/${1}.kill"
	fi

} >"${LogDir}/${1}.kill"

# 生成 kill 文件
local kmark=$(grep "kill -15" "$LogFile" | wc -l)
if test "$kmark" -eq 1; then
	chmod u+x "${LogDir}/${1}.kill"
	echo "Execute file  ${LogDir}/${1}.kill and terminate the strace process"
else
	echo "no pid info,please check ${LogDir}/error.log"
	rm -f "${LogDir}/${1}.kill" "$LogFile"
fi
