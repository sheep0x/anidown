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

# watch for new episodes of animes in watchlist

trap 'echo "watch.sh: An error occured at line $LINENO (please also check your watchlist)" >&2; exit 2' ERR
exec < watchlist

idle=1

while anime=$(line)
do    season=$(line)
      site=$(line)

  # bash will remove \n for us
  ./scan_source.rb "$anime" "$season" "$site" 2>&1 >tmp/video_list
  if [[ ! -s tmp/video_list ]]; then
      echo "Can't find matching source (\`$anime' \`$season' \`$site')"
  else
      trap - ERR
      ./dwrapper.sh "$anime/$season" < tmp/video_list
      case $? in
          0)
              idle=0;;
          1)
              echo "Nothing new for \`$anime' \`$season'";;
          *)
              echo 'watch.sh: An error occured when running downloader' >&2
              exit 2;;
      esac
      trap 'echo "watch.sh: An error occured at line $LINENO (please also check your watchlist)" >&2; exit 2' ERR
  fi

  line > /dev/null || break
done

exit $idle
