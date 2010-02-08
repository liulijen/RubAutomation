#!/usr/bin/env ruby
require "net/ssh"
HOST=""
USER=''
PASS=''

Net::SSH.start(HOST, USER, :password => PASS) do |ssh|
    result = ssh.exec!('ls')
    puts result
end

