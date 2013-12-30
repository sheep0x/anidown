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

# ==================== default values ====================
verbosity=1
logfile=/dev/null
logIOflag=a
switches=''
path=.

# ==================== info ====================
printHelp() { cat; } << EOF
Usage: ./dwrapper.sh [OPTIONS]

-h --help
        Display this message.
-o --output PATH
        Save videos in PATH instead of the default directory.
-c --continue
        Continue previous download. Don't skip episode even if directory exists.
-f --force
        Force re-downloading of every file. Useful when videos are corrupted.
        (could be really slow)
-q --quiet
        Don't print anything to stderr.
-v --verbose
        Print detailed progress to stderr.
-V --very-verbose
        Verbose output plus wget output.
-L --logfile FILE
        Append log (anything not printed to stderr) to FILE.
-O --overwrite-log
        Overwrite exsiting log file instead of appending to it.
-A --append-log
        Append to existing log (usually used to override -O in default configurations).
--no-continue
--no-force
--no-verbose
        Reset options (usually used to override default configurations).
EOF

# ==================== parse ARGV ====================
abort() {
  echo 'dwrapper.sh: wrong arguments'
  printHelp
  exit 2
} >&2

while (($#)); do
  case "$1" in
    -h|--help)
      printHelp
      exit 0
      ;;
    -o|--output)
      (( $# >= 2 )) || abort
      path=$2
      shift
      ;;
    --output=*)
      path=${1#*=};;
    -c|--continue)
      switches+=c;;
    --no-continue)
      switches=${switches//c};;
    -f|--force)
      switches+=f;;
    --no-force)
      switches=${switches//f};;
    -q|--quiet)
      verbosity=0;;
    --no-verbose)
      verbosity=1;;
    -v|--verbose)
      verbosity=2;;
    -V|--very-verbose)
      verbosity=3;;
    -L|--logfile)
      (( $# >= 2 )) || abort
      logfile=$2
      shift
      ;;
    --logfile=*)
      logfile=${1#*=};;
    -O|--overwrite-log)
      logIOflag=w;;
    -A|--append-log-log)
      logIOflag=a;;
  esac
  shift
done

# ==================== output redirections ====================
[[ $logfile =~ / ]] && mkdir -p "${logfile%/*}"
if [[ $logIOflag == w ]]
  then exec 5>$logfile
  else exec 5>>$logfile
fi
case $verbosity in
  0) exec 4>&5 3>&5 2>&5;;
  1) exec 4>&5 3>&5;;
  2) exec 4>&5 3>&2;;
  3) exec 4>&2 3>&2;;
esac
exec 5>&-

# ==================== invoke downloader ====================
# use absolute path, because we'll chdir later
mkdir -p "$path"
cd "$path"
path=$PWD

# XXX $0 must contain at least one slash(/)
cd - > /dev/null
cd "${0%/*}"

set +eE
trap - ERR
./download.sh "$switches" "$path"

# vim: sw=2 sts=2
