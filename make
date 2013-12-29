#! /usr/bin/env bash

# XXX file names should not contain ws

set -eE
mkdir -p bin

for f in *.c
  do gcc -O2 -Wall -o "bin/${f%.*}" "$f"; done

for f in *.sh *.rb; do
  cp "$f" bin/"$f"
  chmod u+x bin/"$f"
done

cp LICENSE bin/LICENSE

# workaround for Debian users in some regions
[[ $(lsb_release -i) =~ Debian ]] && sed -i 's/\(^[^#].*wget\)/\1 -4/g' bin/*.{sh,rb}

wc *.sh *.rb *.c make
