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

# doesn't handle -q, -v, etc; doesn't handle ``--output -h''
usage = <<EOF
Usage:
    #{$0} (-h|--help)
        Display this message.
    #{$0} [OPTIONS]
        Check new episodes in animes specified in watchlist.
        All commandline arguments will be passed to dwrapper.sh.
        For a list of options, see `dwrapper.sh --help'.
EOF

argv = []
outpath = '.'
until ARGV.empty?
  v = ARGV.shift
  argv << v
  case v
    when '-h', '--help'
      print usage
      exit 0
    when '-L', '--logfile'
      argv << ARGV.shift
    when '-o', '--output'
      argv.pop
      outpath = ARGV.shift
    when /(?<=^--output=).*$/
      argv.pop
      outpath = $&
  end
end

require 'fileutils'
FileUtils.mkdir_p 'tmp'
$stdin.reopen('watchlist')

# XXX we don't handle relative path, so be careful not to cd
if $0.include?(?/)
  binpath = File.dirname($0)
  ENV['PATH'] = binpath + ':' + ENV['PATH']
  $: << binpath
end

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

idle = true
have_trouble = false

watched.each_pair do |anime, seasons|
  time = Time.now.strftime('%F %T')
  logfile = "log/#{time}_#{anime}"
  #if logfile.include? ?/
    FileUtils.mkdir_p( File.dirname(logfile) )
  #end

  system *%W{wget -O tmp/search_result http://www.soku.com/t/nisearch/#{anime}}, :err=>[logfile, 'a']
  puts "scanning anime #{anime}"
  res = SokuScanner.scan(IO.read('tmp/search_result'))

  seasons.each_pair do |season, site|
    unless urls = find_source(res, season, site)
      puts "Can't find matching source (`#{anime}' `#{season}' `#{site}')"
      next
    end
    puts "found season #{season}"
    puts "found source #{site}"

    # open(...).puts(...) won't flush the output
    open('tmp/video_list', 'w') {|f| f.puts(urls)}
    # doesn't handle -L and -O
    system *%W{dwrapper.sh -o #{outpath}/#{anime}/#{season} -L #{logfile}}, *argv, :in=>'tmp/video_list', :err=>:out

    case $?.exitstatus
      when 0
        idle = false
      when 1
        puts "Nothing new for `#{anime}' `#{season}'"
      when 3
        have_trouble = true
      else
        $stderr.puts "#{$0}: An error occured when running downloader"
        exit 2
    end
  end
end

exit have_trouble ? 3 : idle ? 1 : 0
