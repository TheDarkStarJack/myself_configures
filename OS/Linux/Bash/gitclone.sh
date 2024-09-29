#!/bin/bash -
#===============================================================================
#
#          FILE: gitclone
#
#         USAGE: gitclone < -o org > | < -u username >
#
#   DESCRIPTION: 用于批量克隆 GitHub 上的组织和用户的项目
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: wxj (DarkStar), 2403220952@qq.com
#  ORGANIZATION:.
#       CREATED: 2024-09-12 15:19:30
#       LASTMOD:
#      REVISION:  ---
#===============================================================================

# set -o nounset # Treat unset variables as an error

# 检查必要的软件和系统
fun_pre() {
  if test "curl --version" && test "jq --version"; then
    # curl --silent --output /dev/null https://github.com/dashboard || echo "curl can not conn  github "
    echo >/dev/null
  else
    echo "please install curl and jq"
    exit 0
  fi
}

case "$1" in
"-o")
  shift 1
  url="https://api.github.com/orgs/${1}/repos?per_page=100&page=1"
  ;;
"-u")
  shift 1
  url="https://api.github.com/users/${1}/repos?per_page=100&page=1"
  ;;
*)
  echo "gitclone < -o org > | < -u username >"
  echo "please check parameter"
  exit
  ;;
esac

fun_clone() {
  if test "curl --silent --output /dev/null $url"; then
    curl $url | jq '.[] | .ssh_url' | xargs printf 'git clone %s & ' | sh
  else
    echo "please check org or username,curl can not conn"
    exit
  fi
}

# main
main() {
  fun_pre
  fun_clone
}

main
