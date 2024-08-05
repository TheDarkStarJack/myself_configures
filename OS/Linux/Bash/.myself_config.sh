#!/bin/bash -
#===============================================================================
#
#          FILE: .myself_config.sh
#
#         USAGE: ./.myself_config.sh
#
#   DESCRIPTION: 
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: wxj (DarkStar), 2403220952@qq.com
#  ORGANIZATION: 
#       CREATED: 08/01/24 17:11
#      REVISION:  ---
#===============================================================================

# set -o nounset                                  # Treat unset variables as an error

# git push 
gitlazy(){
	if [ ! -z "`git --version`" ];then
		if [ -z "$1" ];then
			comment="update config"
		else
			comment="$1"
		fi
		git add --all && git commit -m "$comment" && git push
		if test "$?" -eq 0;then
			echo "push ok"
		else
			echo "push failed, please check "
		fi
	fi
}

