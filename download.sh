#! /usr/bin/env bash

# Copyright 2013 Chen Ruichao <linuxer.sheep.0x@gmail.com>
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# 虽然在不断完善，但是现阶段仍然只是粗糙的hack，所以代码质量比较低
# 具体细节参考以前的代码（dump.sh, dantalian.rb, etc）
# no CWD checking
# 仅针对iqiyi和youku，其他网站现在处理不了，但是应该是同理

# convention:
# &1 - result
# &2 - report
# &3 - log
# &4 - log (more verbose, only wget outputs go here)

#set -x
set -eE
trap 'echo "download.sh: An error occured at line $LINENO" >&2; exit 2' ERR

# TODO parse ARGV
loglevel=1
#logfile=/dev/null
logfile=log
switches=s
path=output/$1

mkdir -p tmp

exec 5>>$logfile
case $loglevel in
  0) exec 4>&5 3>&5 2>&5;;
  1) exec 4>&5 3>&5;;
  2) exec 4>&5 3>&2;;
  3) exec 4>&2 3>&2;;
esac
exec 5>&-






# customize log format here
#say() { echo "$@"; }
say() { echo "[$(date '+%F %T')]" "$@"; }

# try to download $url. retry if failed
xget() {
  local output="$1" url="$2"
  say "downloading $output from $url"
  until
    wget -U '' -O "$output" "$url" 2>&4
    [[ -s $output ]]
  do
    say 'empty output, retrying'
  done
  say "$output downloaded"
} >&4

parseIqiyi() {
  local L
  while L=$(line); do
    xget tmp/iqiyi_json "$L"
    sed 's/.*"\(http[^"]*\)".*/\1\n/' tmp/iqiyi_json
  done
}

# assumption: qscan_form.rb and scan_form.rb never return 2
parseVideo() {
  (( $# == 1 ))   # assertion
  local url=$1
  if [[ $url =~ .*redirect.* ]]
    then url=$(sed -e 's|^.*url=||;s|&.*$||' <<< "$url")
    else url=$(sed -e 's|%|%25|g;s|/|%2F|g;s|:|%3A|g;s|?|%3F|g;s|=|%3D|g;s|&|%26|g' <<< "$url")
  fi
  url="http://www.flvcd.com/parse.php?kw=$url&format=super"

  # a quick glance to see if we've got the URLs
  xget tmp/parse_page "$url"
  say 'trying simple resolution' >&3
  ./qscan_form.rb < tmp/parse_page && return

  say 'trying general resolution' >&3
  until
    local xdown_redir_url=$(./scan_form.rb < tmp/parse_page)
    xget tmp/xdown_redir "$xdown_redir_url"
    (( $(cat tmp/xdown_redir | wc -c) > 84 ))
  do
    say 'failed to resolve, retrying' >&2
    xget tmp/parse_page "$url"
  done
  #local xdown_url=$(sed -n 's,.*\(http://www.flvcd.com/xdown.php?id=[0-9]\+\).*,\2\n,p' tmp/xdown_redir)
  #xget tmp/xdown "$xdown_url"
  # $data_url has no \n
  local data_url=$(sed -n 's,.*xdown.php?id=\([0-9]\+\).*,http://www.flvcd.com/diy/diy00\1.htm,p' tmp/xdown_redir)
  xget tmp/data "$data_url"

  case "$(grep '^<F>' tmp/data)" in
    *iqiyi*)
      # tmp/iqiyi_list is for debugging use
      sed -n 's/^<C>\(.*\)/\1/p' tmp/data | tee tmp/iqiyi_list | parseIqiyi
      ;;
    *youku*|*letv*|*56.com*)
      # `*youku*' is for both youku and tudou
      sed -n 's/^<U>\(.*\)/\1/p' tmp/data
      ;;
    *)
      # not implemented yet
      false
      ;;
  esac
}


# return 1 when failed (usually because the resolved URLs expired)
fetch() {
  (( $# == 1 ))   # assertion
  mkdir -p "$1"
  say "fetching $1" >&3
  local idle=1

  declare -i cnt=0
  local url
  while url=$(line); do
    cnt=cnt+1
    if [[ $switches =~ f ]]; then
      say "re-downloading part$cnt" >&2
    elif [[ -e $1/$cnt ]]; then
      say "skipping part$cnt (file already exists)" >&3
      continue
    else
      say "downloading part$cnt" >&2
    fi

    idle=0
    say "URL: $url" >&3
    wget -U '' -O "$1/$cnt" "$url" 2>&4 || return 1
  done

  (( idle )) && say "nothing done in $1" >&2
  return 0
}




idle=1

declare -i cnt=0
while L=$(line); do
  cnt=cnt+1

  if [[ ! $switches =~ [fs] && -d $path/$cnt ]]; then
    say "skipping episode $cnt (directory already exists)" >&2
    continue
  fi
  idle=0

  say "doing episode $cnt" >&2
  until
    parseVideo "$L" > tmp/file_list
    say 'resolution done' >&3
    fetch "$path/$cnt" < tmp/file_list
  do
    say 'download failed, resolving again' >&2
  done
  say "episode $cnt done"$'\n\n' >&2
done

exit $idle

# vim: sw=2 sts=2
