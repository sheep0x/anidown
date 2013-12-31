#! /usr/bin/env ruby
# encoding: UTF-8

=begin
Copyright 2013 Chen Ruichao <linuxer.sheep.0x@gmail.com>

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

# XXX no error checking

# site name
sn = {
  1 =>'土豆', 2 =>'56',    3 =>'新浪', 6 =>'搜狐',
  8 =>'凤凰', 9 =>'激动',  10=>'酷6"', 14=>'优酷',
  15=>'CNTV', 16=>'电影网',17=>'乐视', 19=>'爱奇艺',
  27=>'腾讯', 130=>'风行', 131=>'华数'
}

# season pattern
ssnp = /<div class="G">.*?title="(.*?)".*?<div class="T">(.*?)<!--T end-->/m
# source pattern
srcp = /<div class='linkpanels site(.*?)'>.*?<ul.*?((?:<li>.*?<\/li>)*?)\s*?<\/ul>/m
# video pattern
vidp = /<li><a href='(.*?)'.*?>.*?<\/li>/m


redir=ARGV[3]       # nil if not supplied
`wget -O tmp/search_result 'http://www.soku.com/t/nisearch/#{ARGV[0]}' #{redir}`
$stderr.puts "scanning anime #{ARGV[0]}"
open('tmp/search_result').read.scan(ssnp) do |title, s|
  $stderr.puts "found season #{title}"
  next if title != ARGV[1]
  s.scan srcp do |site, w|
    site = site.to_i
    $stderr.puts "found source #{sn[site]}(id: #{site})"
    next if sn[site] != ARGV[2]
    w.scan(vidp) {|v| puts v[0]}
  end
end
