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

require 'fileutils'

FileUtils.mkdir_p 'tmp'
$stdin.reopen('watchlist')

usage = <<EOF
Usage:
    #{$0} (-h|--help)
        Display this message.
    #{$0} [OPTIONS]
        Check new episodes in animes specified in watchlist.
        All commandline arguments will be passed to dwrapper.sh.
        For a list of options, see `dwrapper.sh --help'.
EOF
if ARGV.include?('-h') || ARGV.include?('--help')
  print usage
  exit 0
end

# XXX we don't handle relative path, so be careful not to cd
$0.include?(?/) && ENV['PATH'] = File.dirname($0) + ':' + ENV['PATH']

idle = true

while $stdin.gets('')
  anime, season, site = $_.split("\n")

  time = Time.now.strftime('%F %T')
  logfile = "log/#{time}_#{anime}"
  #if logfile.include? ?/
    FileUtils.mkdir_p( File.dirname(logfile) )
  #end

  unless system('scan_source.rb', anime, season, site, logfile, :err=>:out, :out=>'tmp/video_list')
    $stderr.puts "#{$0}: An error occured when scanning source sites"
    exit 2
  end

  unless test(?s, 'tmp/video_list')
    puts "Can't find matching source (`#{anime}' `#{season}' `#{site}')"
  else
    system *%W{dwrapper.sh -o output/#{anime}/#{season} -L #{logfile}}, *ARGV, :in=>'tmp/video_list'
    case $?.exitstatus
      when 0
        idle = false
      when 1
        puts "Nothing new for `#{anime}' `#{season}'"
      else
        $stderr.puts "#{$0}: An error occured when running downloader"
        exit 2
    end
  end
end

exit idle ? 1 : 0
