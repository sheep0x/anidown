#! /usr/bin/env ruby1.8

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

def escape s
  es = ''
  s.each_char do |c|
    es += case c
            when /\w/, '.'  then c
            when ' '        then '+'
            else sprintf('%%%02X', c[0].ord)
          end
  end
  es
end

url = String.new # make it global
params = []

# be careful. there could be another form for get_m3u.php
$stdin.read.scan /<form name="mform".*?<\/form>/m do |form|
  form.scan(/action="(.*?)"/){ |u| url,=u }
  form.scan /<input .*? name="(.*?)" value="(.*?)">/ do |param|
    params << param[0] + '=' + escape(param[1])
  end
end

url = url + '?' + params.join('&')
puts url
