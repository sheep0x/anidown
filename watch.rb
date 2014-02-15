#! /usr/bin/env ruby

=begin
Copyright 2014 Chen Ruichao <linuxer.sheep.0x@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
=end

# watch for new episodes of animes in watchlist

# ==================== handle argv ====================
usage = <<EOF
Usage: #{$0} [OPTIONS]

Check new episodes in animes specified in watchlist.

-h --help
        Display this message.
-o --output PATH
        Save videos in PATH instead of the default directory.
-L --logpath PATH
        Save logs in PATH instead of the default directory.
--[no-]debug
        Use ./tmp as the temporary directory, and don't remove it before exiting.
        (by default, Anidown uses /tmp/anidown.XXXXXXXXXX)

The following commandline arguments will be passed to dwrapper.sh:
    -c --[no-]continue
    -f --[no-]force
    -q --quiet
       --no-verbose
    -v --verbose
    -V --very-verbose
EOF

argv = []
outpath = '.'
logpath = nil
debug=$DEBUG

until ARGV.empty?
  v = ARGV.shift
  case v
    when '-h', '--help'
      print usage
      exit 0
    when '--debug'
      debug=true
    when '--no-debug'
      debug=false
    when /(?<=^--output=).*$/,  '-o', '--output'
      outpath = $& || ARGV.shift
    when /(?<=^--logpath=).*$/, '-L', '--logpath'
      logpath = $& || ARGV.shift
    when *%w( -c --continue
              -f --force
              -q --quiet
              -v --verbose
              -V --very-verbose
              --no-continue
              --no-force
              --no-verbose
            )
      argv << v
    else
      $stderr.puts "#{$0}: wrong arguments"
      exit 2
  end
end

argv << (debug ? '--debug' : '--no-debug')

# ==================== preparation ====================
require 'fileutils'

begin
  if debug
    FileUtils.mkdir_p 'tmp'
    tmpd = 'tmp'
  else
    require 'tmpdir'
    tmpd = Dir.mktmpdir('anidown-')
    trap('EXIT') { FileUtils.rm_r(tmpd) }
  end
rescue
  $stderr.puts "#{$0}: failed to create temporary directory"
  exit 2
end

# XXX we don't handle relative path, so be careful not to cd
if $0.include?(?/)
  binpath = File.dirname($0)
  ENV['PATH'] = binpath + ':' + ENV['PATH']
  $: << binpath
end

# ==================== watchlist preparation ====================
$stdin.reopen('watchlist')

watched = Hash.new { |h, k| h[k] = {} }

while $stdin.gets('')
  a, s, site = $_.split("\n")
  watched[a][s] = site
end

# detect name conflict
raise LoadError unless require 'scan_source'

# only return the first match
def find_source(slist, season, site)
  for s in slist
    next unless s.title == season
    for src in s.sources
      return src.episodes if site == SokuScanner::SiteName[src.site]
    end
  end
  nil
end

# ==================== real work ====================
idle = true
have_trouble = false

FileUtils.mkdir_p(logpath) if logpath

watched.each_pair do |anime, seasons|
  time = Time.now.strftime('%F %T')
  logfile = logpath ? "#{logpath}/#{time}_#{anime}" : '/dev/null'

  system *%W{wget -O #{tmpd}/search_result http://www.soku.com/t/nisearch/#{anime}}, :err=>[logfile, 'a']
  exit 130 if $?.termsig == 2 # SIGINT

  puts "scanning anime #{anime}"
  res = SokuScanner.scan(IO.read("#{tmpd}/search_result"))

  seasons.each_pair do |season, site|
    unless urls = find_source(res, season, site)
      puts "Can't find matching source (`#{anime}' `#{season}' `#{site}')"
      next
    end
    puts "found season #{season}"
    puts "found source #{site}"

    # open(...).puts(...) won't flush the output
    open("#{tmpd}/video_list", 'w') {|f| f.puts(urls)}
    system *%W{dwrapper.sh -o #{outpath}/#{anime}/#{season} -L #{logfile} -A}, *argv, :in=>"#{tmpd}/video_list", :err=>:out

    case $?.exitstatus || $?.termsig+128
      when 0
        idle = false
      when 1
        puts "Nothing new for `#{anime}' `#{season}'"
      when 3
        have_trouble = true
      when 130
        exit 130 # SIGINT
      else
        $stderr.puts "#{$0}: An error occured when running downloader"
        exit 2
    end
  end
end

exit have_trouble ? 3 : idle ? 1 : 0
