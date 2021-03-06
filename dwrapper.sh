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

set -eE
trap 'echo "dwrapper.sh: An unexpected error occured at line $LINENO" >&2; exit 2' ERR

# ==================== default values ====================
verbosity=1
logfile=/dev/null
logIOflag=a
switches=''
path=.

# ==================== info ====================
printHelp() { cat; } << EOF
Usage: dwrapper.sh [OPTIONS] [URL]

Download a video from URL. If URL is omitted, read a list of videos from stdin
and download them.

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
        Verbose output plus Wget output.
-L --logfile FILE
        Append log (anything not printed to stderr) to FILE.
-O --overwrite-log
        Overwrite exsiting log file instead of appending to it.
-A --append-log
        Append to existing log (usually used to override -O in default configurations).
--debug
        Use ./tmp as the temporary directory, and don't remove it before exiting.
        (by default, Anidown uses /tmp/anidown.XXXXXXXXXX)
--no-continue
--no-force
--no-debug
--no-verbose
        Reset options (usually used to override default configurations).
EOF

# ==================== parse ARGV ====================
abort() {
  echo "dwrapper.sh: $1"
  echo "Try \`dwrapper.sh --help' for more information"
  exit 2
} >&2

# variable `url' is defined iff URL is supplied in cmdline arguments
add_url() {
  [[ -v url ]] && abort 'too many URLs'
  url=$1
}

while (( $# > 0 )); do
  v=$1
  shift

  # resetting positional arguments could be slow, but other methods of handling
  # argv are more complex and error-prone
  if [[ $v =~ ^-[^-].+$ ]]; then
    if [[ ${v:1:1} =~ [oL] ]]; then
      set -- "${v:2}" "$@"
    elif [[ ! ${v:2:1} == - ]]; then
      set -- "-${v:2}" "$@"
    else
      abort "invalid option '-'"
    fi
    v=${v::2}
  fi

  case "$v" in
    -h|--help)
      printHelp
      exit 0
      ;;
    -o|--output)
      (( $# >= 1 )) || abort "option '-o' requires an argument"
      path=$1
      shift
      ;;
    --output=*)
      path=${v#*=};;
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
      (( $# >= 1 )) || abort "option '-L' requires an argument"
      logfile=$1
      shift
      ;;
    --logfile=*)
      logfile=${v#*=};;
    -O|--overwrite-log)
      logIOflag=w;;
    -A|--append-log)
      logIOflag=a;;
    --debug)
      switches+=d;;
    --no-debug)
      switches=${switches//d};;
    --)
      for url in "$@"; do add_url "$url"; done
      break
      ;;
    -*)
      abort "invalid option '$v'";;
    *)
      add_url "$v";;
  esac
done

# ==================== output redirections ====================
[[ $logfile =~ / ]] && mkdir -p -- "${logfile%/*}"
if [[ $logIOflag == w ]]
  then exec 5>"$logfile"
  else exec 5>>"$logfile"
fi
case $verbosity in
  0) exec 4>&5 3>&5 2>&5;;
  1) exec 4>&5 3>&5;;
  2) exec 4>&5 3>&2;;
  3) exec 4>&2 3>&2;;
esac
exec 5>&-

# ==================== invoke downloader ====================
# XXX we don't handle relative path, so be careful not to cd
[[ $0 =~ / ]] && {
  binpath=${0%/*}
  if [[ ! $binpath =~ : ]] && binpath=$( (CDPATH='' cd -- "$binpath" && echo -n "$PWD") )
    then export PATH="$binpath:$PATH"
    else echo 'dwrapper.sh: failed to set PATH' >&2; exit 2
  fi
}

set +eE
trap - ERR
if [[ -v url ]]
  then exec download.sh "$switches" "$path" "$url"
  else exec batch.sh    "$switches" "$path"
fi

# vim: sw=2 sts=2
