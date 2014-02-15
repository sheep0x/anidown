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

disableTrap() { set +eE; trap - ERR; }
enableTrap() {
  set -eE
  trap 'echo "batch.sh: An unexpected error occured at line $LINENO" >&2; exit 2' ERR
}
enableTrap

(( $# == 2 ))   # assertion

switches=$1
path=$2

# customize log format here (please do not put -- in echo's argv)
#say() { echo "$@"; }
say() { echo "[$(date '+%F %T')]" "$@"; }

idle=1
have_trouble=0

declare -i cnt=0
while L=$(line); do
  cnt=cnt+1

  if [[ -z $L ]]; then
    say "skipping episode $cnt (URL not supplied)" >&3
    continue
  fi

  if [[ ! $switches =~ [fc] && -d $path/$cnt ]]; then
    say "skipping episode $cnt (directory already exists)" >&2
    continue
  fi

  say "doing episode $cnt" >&2
  disableTrap
  download.sh "$switches" "$path/$cnt" "$L"
  case $? in
    0)
      idle=0;;
    1)
      ;; # this could happen when --continue is used
    3)
      have_trouble=1;;
    130)
       kill -s SIGINT $$;;
    *)
      echo 'batch.sh: An error occured when running downloader' >&2
      exit 2;;
  esac
  enableTrap
  say "episode $cnt done"$'\n\n' >&2
done

(( have_trouble )) && exit 3
exit $idle

# vim: sw=2 sts=2
