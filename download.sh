#! /usr/bin/env bash

# Copyright 2013, 2014 Chen Ruichao <linuxer.sheep.0x@gmail.com>
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

# convention:
# &1 - result
# &2 - report
# &3 - log
# &4 - log (more verbose, almost only wget outputs go here)

#set -x
set -eE
trap 'echo "download.sh: An error occured at line $LINENO" >&2; exit 2' ERR

(( $# == 3 ))   # assertion

switches=$1
path=$2
videourl=$3
mkdir -p tmp






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

parseTudou() {
  local L
  while L=$(line); do
    xget tmp/tudou_reply "$L"
    sed -n 's,.*<f.*>\(http[^<]*\)</f>.*,\1,; s/&amp;/\&/g; p; q' tmp/tudou_reply
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
  url="http://www.flvcd.com/parse.php?kw=$url&format=real"

  xget tmp/parse_page "$url"

  # a quick glance to see if we've got the URLs
  say 'trying simple resolution' >&3
  qscan_form.rb < tmp/parse_page && return

  say 'trying general resolution' >&3
  until
    local xdown_redir_url
    if ! xdown_redir_url=$(scan_form.rb < tmp/parse_page); then
      say 'failed to resolve, please check if the video is valid' >&2
      exit 3
    fi
    xget tmp/xdown_redir "$xdown_redir_url"
    (( $(cat tmp/xdown_redir | wc -c) > 84 ))
  do
    say 'failed to retrieve data, retrying' >&2
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
    *tudou*)
      # tmp/tudou_list is for debugging use
      sed -n 's/^<C>\(.*\)/\1/p' tmp/data | tee tmp/tudou_list | parseTudou
      ;;
    *youku*|*letv*|*56.com*|*funshion*|*qq.com*|*joy.cn*)
      # some videos are shared by youku and tudou
      sed -n 's/^<U>\(.*\)/\1/p' tmp/data
      ;;
    *)
      say 'source site not supported yet, exiting' >&2
      exit 3
      ;;
  esac
}


# return 1 when failed (usually because the resolved URLs expired)
# otherwise return 0, even if we didn't do anything
fetch() {
  (( $# == 1 ))   # assertion
  mkdir -p "$1"
  say "fetching $1" >&3
  local cont osize

  declare -i cnt=0
  local url
  while url=$(line); do
    cnt=cnt+1
    local file=$1/$cnt
    if [[ ! -e $file ]]; then
      cont=''; say "downloading part$cnt" >&2
    elif [[ $switches =~ f ]]; then
      cont=''; say "re-downloading part$cnt" >&2
    else
      cont=-c; say "continue downloading part$cnt" >&2
      osize=$(stat -c %s "$file")
    fi

    say "URL: $url" >&3
    wget $cont --progress=dot:mega -U '' -O "$file" "$url" 2>&4 || return 1
    if [[ $cont == -c && $(stat -c %s "$file") == $osize ]]
      then say "skipping part$cnt (file is already complete)" >&3
      else idle=0
    fi
  done
}




idle=1
until
  parseVideo "$videourl" > tmp/file_list
  say 'resolution done' >&3
  fetch "$path" < tmp/file_list
do
  say 'download failed, resolving again' >&2
done

(( idle )) && say "nothing done for $path (files are already complete)" >&2
exit $idle

# vim: sw=2 sts=2
