#! /usr/bin/env bash

set -eEv
mkdir -p bin

gcc -O2 -Wall -o bin/escape     escape.c
cp  download.sh     bin/download.sh
cp  qscan_form.rb   bin/qscan_form.rb
cp  scan_form.rb    bin/scan_form.rb
cp  scan_source.rb  bin/scan_source.rb
cp  watch.sh        bin/watch.sh

set +v
# workaround for Debian users in some regions
[[ $(lsb_release -i) =~ Debian ]] && sed -i 's/wget/wget -4/g' bin/*.{sh,rb}

wc download.sh escape.c make qscan_form.rb scan_form.rb scan_source.rb watch.sh
