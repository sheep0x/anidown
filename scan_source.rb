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

module SokuScanner
  SiteName = {
    1 =>'土豆',       2 =>'56',       3 =>'新浪',     6 =>'搜狐',
    8 =>'凤凰',       9 =>'激动',     10=>'酷6',      12=>'六间房',
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
  SiteName.default = '未知'


  def self.scan(htmlsrc)
    # season pattern
    ssnp = /<div class="G">.*?title="(.*?)".*?<div class="T">(.*?)<!--T end-->/m
    # source pattern
    srcp = /<div class='linkpanels site(.*?)'.*?>.*?(<ul class=.linkpanel.*?)<\/div>/m
    grpp = /<ul.*?id="group\d+".*?>(.*?)<\/ul>/m
    # video pattern
    vidp = %r{<li(?: class="(?:ex|xe)")?><a href='(.*?)'.*?>(\d+?)</a>.*?</li>}m
    novidp = /<li class="disabled(?: ex)?">(\d+?)<\/li>/m


    require 'ostruct'

    # seasons
    htmlsrc.scan(ssnp).collect do |title, s|

      # sources
      slist = s.scan(srcp).collect do |site, w|

        # episodes
        elist = []

        w.scan(grpp) do |g,|
          g.scan(vidp) {|url, no| elist[no.to_i-1]=url}
          g.scan(novidp) {|no,|   elist[no.to_i-1]=nil}
        end

        OpenStruct.new(:site => site.to_i, :episodes => elist)
      end

      OpenStruct.new(:title => title, :sources => slist)
    end
  end
end


# XXX no error checking

if __FILE__ == $0
  res = SokuScanner.scan($stdin.read)
  for s in res
    $stderr.puts "found season #{s.title}"
    next unless s.title == ARGV[0]
    for src in s.sources
      sid = src.site
      n = SokuScanner::SiteName[sid]
      $stderr.puts "found source #{n}(id: #{sid})"
      puts(src.episodes) if n == ARGV[1]
    end
  end
end
