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

set -eE
trap 'echo "dwrapper.sh: An error occured at line $LINENO" >&2; exit 2' ERR

# XXX $0 must contain at least one slash(/)
cd "${0%/*}"

loglevel=1
#logfile=/dev/null
logfile=log
switches=s
path=output/$1

exec 5>>$logfile
case $loglevel in
  0) exec 4>&5 3>&5 2>&5;;
  1) exec 4>&5 3>&5;;
  2) exec 4>&5 3>&2;;
  3) exec 4>&2 3>&2;;
esac
exec 5>&-

./download.sh $switches $path

# vim: sw=2 sts=2
