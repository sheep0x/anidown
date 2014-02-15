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

set -eE
trap 'echo "download.sh: An unexpected error occured at line $LINENO" >&2; exit 2' ERR

(( $# == 3 ))   # assertion

switches=$1
path=$2
videourl=$3





# customize log format here (please do not put -- in echo's argv)
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
    xget "$tmpd"/iqiyi_json "$L"
    sed 's/.*"\(http[^"]*\)".*/\1\n/' "$tmpd"/iqiyi_json
  done
}

parseTudou() {
  local L
  while L=$(line); do
    xget "$tmpd"/tudou_reply "$L"
    sed -n 's,.*<f.*>\(http[^<]*\)</f>.*,\1,; s/&amp;/\&/g; p; q' "$tmpd"/tudou_reply
  done
}

# assumption: qscan_form.rb and scan_form.rb never return 2
parseVideo() {
  (( $# == 1 ))   # assertion
  local url=$1

  # handle soku redirection
  if [[ $url =~ redirect ]]; then
    url=$(sed -e 's|^.*[?&]url=||;s|&.*$||' <<< "$url")
    # unescape
    url=$(sed -e 's|%2F|/|g;s|%3A|:|g;s|%3F|?|g;s|%3D|=|g;s|%26|&|g;s|%25|%|g' <<< "$url")
  fi

  # turn http://www.funshion.com/subject/play/43280/25
  # into http://www.funshion.com/vplay/m-43280.e-25
  if [[ $url =~ ^'http://www.funshion.com/subject/play/'[[:digit:]]+/[[:digit:]]+$ ]]
    then url=$(sed -e 's,^.*/\([0-9]\+\)/\([0-9]\+\)$,http://www.funshion.com/vplay/m-\1.e-\2,' <<< "$url")
  fi

  # escape the url
  url=$(sed -e 's|%|%25|g;s|/|%2F|g;s|:|%3A|g;s|?|%3F|g;s|=|%3D|g;s|&|%26|g' <<< "$url")
  url="http://www.flvcd.com/parse.php?kw=$url&format=real"

  xget "$tmpd"/parse_page "$url"

  # a quick glance to see if we've got the URLs
  say 'trying simple resolution' >&3
  qscan_form.rb < "$tmpd"/parse_page && return

  say 'trying general resolution' >&3
  until
    local xdown_redir_url
    if ! xdown_redir_url=$(scan_form.rb < "$tmpd"/parse_page); then
      say 'failed to resolve, please check if the video is valid' >&2
      exit 3
    fi
    xget "$tmpd"/xdown_redir "$xdown_redir_url"
    (( $(cat "$tmpd"/xdown_redir | wc -c) > 84 ))
  do
    say 'failed to retrieve data, retrying' >&2
    xget "$tmpd"/parse_page "$url"
  done
  #local xdown_url=$(sed -n 's,.*\(http://www.flvcd.com/xdown.php?id=[0-9]\+\).*,\2\n,p' "$tmpd"/xdown_redir)
  #xget "$tmpd"/xdown "$xdown_url"
  # $data_url has no \n
  local data_url=$(sed -n 's,.*xdown.php?id=\([0-9]\+\).*,http://www.flvcd.com/diy/diy00\1.htm,p' "$tmpd"/xdown_redir)
  xget "$tmpd"/data "$data_url"

  case "$(grep '^<F>' "$tmpd"/data)" in
    *iqiyi*)
      sed -n 's/^<C>\(.*\)/\1/p' "$tmpd"/data | dbg iqiyi_list | parseIqiyi
      ;;
    *tudou*)
      sed -n 's/^<C>\(.*\)/\1/p' "$tmpd"/data | dbg tudou_list | parseTudou
      ;;
    *youku*|*letv*|*56.com*|*funshion*|*qq.com*|*joy.cn*)
      # some videos are shared by youku and tudou
      sed -n 's/^<U>\(.*\)/\1/p' "$tmpd"/data
      ;;
    *)
      say 'source site not supported yet, exiting' >&2
      exit 3
      ;;
  esac
}


# return 1 when failed (usually because the resolved URLs expired)
# otherwise return 0, even if we didn't do anything
# print "not idle" to &1 if we did something; print nothing if idle
fetch() {
  (( $# == 1 ))   # assertion
  local path=$1
  mkdir -p -- "$path"
  say "fetching $path" >&3
  local cont oldsize

  declare -i cnt=0
  local url
  while url=$(line); do
    cnt+=1
    local file=$path/$cnt
    if [[ ! -e $file ]]; then
      cont=''; say "downloading block$cnt" >&2
    elif [[ $switches =~ f ]]; then
      cont=''; say "re-downloading block$cnt" >&2
    else
      cont=-c; say "continue downloading block$cnt" >&2
      oldsize=$(stat -c %s -- "$file")
    fi

    say "URL: $url" >&3
    wget $cont --progress=dot:mega -U '' -O "$file" -- "$url" 2>&4 || return 1
    if [[ $cont == -c && $(stat -c %s -- "$file") == $oldsize ]]
      then say "nothing done for block$cnt (file is already complete)" >&3
      else echo 'not idle'
    fi
  done
}





if [[ $switches =~ d ]]; then
  dbg() { tee "tmp/$1"; }
  mkdir -p tmp && tmpd=tmp
else
  dbg() { cat; }
  tmpd=$(mktemp -d -t "anidown.XXXXXXXXXX") && trap "rm -r '$tmpd'" EXIT
fi || { say 'failed to create temporary directory' >&2; exit 2; }

set -o pipefail

idle_report=''
until
  idle_report+=$(parseVideo "$videourl" | dbg file_list | fetch "$path")
do
  # SIGINT
  (( $? == 130 )) && kill -s SIGINT $$
  say 'download failed, resolving again' >&2
done

if [[ -z $idle_report ]]; then
  say "nothing done for $path (files are already complete)" >&2
  exit 1
else
  exit 0
fi

# vim: sw=2 sts=2
