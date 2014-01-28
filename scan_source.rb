#! /usr/bin/env ruby
# encoding: UTF-8

=begin
Copyright 2013, 2014 Chen Ruichao <linuxer.sheep.0x@gmail.com>

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
  1 =>'土豆',       2 =>'56',       3 =>'新浪',     6 =>'搜狐',
  8 =>'凤凰',       9 =>'激动',     10=>'酷6"',     12=>'六间房',
  13=>'中关村在线', 14=>'优酷',     15=>'CNTV',     16=>'电影网',
  17=>'乐视',       19=>'爱奇艺',   24=>'芒果',     25=>'爱拍游戏',
  26=>'音悦台',     27=>'腾讯',     28=>'迅雷',     31=>'PPTV',
  35=>'看看新闻网', 36=>'天翼视讯', 39=>'时光网',   41=>'爆米花',
  42=>'东方宽频',   44=>'NBA中国',  45=>'17173视频游戏',
  48=>'糖豆网',     69=>'1财网',    80=>'哔哩哔哩', 83=>'PPS',
  84=>'悠视网',     87=>'风光网',   115=>'环球网',  116=>'来车网',
  117=>'爱财经',    126=>'4399',    129=>'豆瓣网',  130=>'风行',
  131=>'华数',      132=>'暴风影音'
}
sn.default = '未知'

# season pattern
ssnp = /<div class="G">.*?title="(.*?)".*?<div class="T">(.*?)<!--T end-->/m
# source pattern
srcp = %r{<div class='linkpanels site(.*?)'.*?>.*?(<ul class=.linkpanel.*?)</div>}m
grpp = %r{<ul.*?id="group\d+".*?>(.*?)</ul>}m
# video pattern
vidp = %r{<li(?: class="(?:ex|xe)")?><a href='(.*?)'.*?>(\d+?)</a>.*?</li>}m
novidp = %r{<li class="disabled(?: ex)?">(\d+?)</li>}m


logfile = ARGV[3] || '/dev/null'
system *%W{wget -O tmp/search_result http://www.soku.com/t/nisearch/#{ARGV[0]}}, :err=>[logfile, 'a']
$stderr.puts "scanning anime #{ARGV[0]}"
open('tmp/search_result').read.scan(ssnp) do |title, s|
  $stderr.puts "found season #{title}"
  next if title != ARGV[1]
  s.scan srcp do |site, w|
    site = site.to_i
    $stderr.puts "found source #{sn[site]}(id: #{site})"
    next if sn[site] != ARGV[2]
    result = Array.new
    w.scan(grpp) do |g,|
      g.scan(vidp) {|url, no| result[no.to_i-1]=url}
      g.scan(novidp) {|no,|   result[no.to_i-1]=nil}
    end
    puts result
  end
end
