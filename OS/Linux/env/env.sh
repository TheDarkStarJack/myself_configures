#!/bin/bash -
#===============================================================================
#
#          FILE: env
#
#         USAGE: env [args1] [args2]
#
#   DESCRIPTION:.
#
#       OPTIONS: ---
#  REQUIREMENTS: ---
#          BUGS: ---
#         NOTES: ---
#        AUTHOR: wxj (DarkStar), 2403220952@qq.com
#  ORGANIZATION:.
#       CREATED: 2024-09-29 11:48:04
#       LASTMOD:
#      REVISION:  ---
#===============================================================================

# set -o nounset # Treat unset variables as an error

fun_getenv() {
  readonly user_profile="$HOME/.bash_profile"
}

fun_setenv() {
  fun_getenv
  readonly work_dir=$(pwd)
  readonly mark_start="## myself env configure start"
  readonly mark_end="## myself env configure end"
  readonly mark=$(sed -n '/'"$mark_start"'/,/'"$mark_end"'/p' $user_profile | wc -l)
  if [[ "$mark" -lt 1 ]]; then
    dtime=$(date +"%m%d%H%M")
    cp "$user_profile" "$user_profile".bak"$dtime"
    echo -n "
    $mark_start
    source $work_dir/alias
    source $work_dir/.PS1
    $mark_end
    " >>"$user_profile"
    echo "ok !!!!!!!" && source "$user_profile"
  else
    echo "had myself env, please check."
    exit 0
  fi
}

main() {
  fun_setenv
}

##
main
