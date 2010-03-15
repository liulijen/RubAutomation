require 'pty'
require 'expect'

$expect_verbose = true
PTY.spawn("ssh orthrus@#{ARGV[0]}") do |reader, writer, pid|
  reader.expect(/^.*password:/)
  writer.puts("cisco123\r")
  reader.expect(/^Orthrus-sip\#/)
  writer.puts("dbg\r")
  reader.expect('>')
  writer.puts("switch MXP\r")
  reader.expect('>')
  writer.puts("sa pcu show-server\r")
  reader.expect(/^exit.*/)
  answer = reader.gets
  puts "\n\nAnswer = #{answer}"
end

def spawnSSH
  reader.expect(/^.*password:/)
  writer.puts("cisco123\r")
  reader.expect(/^Orthrus-sip\#/)
  writer.puts("dbg\r")
  reader.expect('>')
  writer.puts("switch MXP\r")
  reader.expect('>')
  writer.puts("sa pcu show-server\r")
  reader.expect(/^exit.*/)
  answer = reader.gets
  puts "\n\nAnswer = #{answer}"
end
