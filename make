#! /usr/bin/env bash

# XXX file names should not contain ws

set -eE
mkdir -p bin

shopt -s nullglob

for f in *.sh *.rb; do
  echo "copying $f"
  cp "$f" bin/"$f"
  chmod u+x bin/"$f"
done

cp LICENSE bin/LICENSE

# workaround for Debian users in some regions
[[ $(lsb_release -i) =~ Debian ]] && sed -i 's/\(^[^#].*wget\)/\1 -4/g' bin/*.{sh,rb}

wc *.sh *.rb *.c make
