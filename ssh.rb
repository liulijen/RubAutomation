#!/usr/bin/env ruby
require "net/ssh"
HOST="leeva.twbbs.org"
USER='gglong'
PASS='gglong123321'

Net::SSH.start(HOST, USER, :password => PASS) do |ssh|
    result = ssh.exec!('ls')
    puts result
end

