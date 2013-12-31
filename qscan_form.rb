#! /usr/bin/env ruby

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

unless String.method_defined?(:encode)
  require 'iconv'
  class String
    def encode(to, from)
      Iconv.conv(to, from, self)
    end
  end
end

$stdin.read.encode('UTF-8', 'GB2312').scan /<input type="hidden" name="inf" value="(.*?)"\/>/ do |urls,|
  puts urls.split('|')
  exit 0
end

exit 1
