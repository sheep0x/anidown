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

params = []

url = String.new # make it global

# be careful. there could be another form for get_m3u.php
$stdin.read.scan /<form name="mform".*?<\/form>/m do |form|
  # TODO 这句应该有更好的写法
  # TODO 为什么这里不能用{|u| url,=u}？
  form.scan /action="(.*?)"/ do |u| url,=u end
  form.scan /<input .*? name="(.*?)" value="(.*?)">/ do |param|
    params << "#{param[0]}=#{`bash -c './escape <<< "#{param[1]}"'`}"
    # 目测默认的shell是sh, 所以这句不能用: params << "#{param[0]}=#{`./escape <<< "#{param[1]}";`}"
  end
end

url="#{url}?#{params.join('&')}"

puts url
