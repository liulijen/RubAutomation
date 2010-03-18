#!/usr/bin/env ruby
require 'net/ssh'
USER='orthrus'
PASS='cisco123'

Net::SSH.start(ARGV[0], USER, :password => PASS) do |ssh|
    result = ssh.exec!('?')
    puts result
end

