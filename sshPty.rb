require 'pty'
require 'expect'

$expect_verbose = true

#def spawnSSH
  reader, writer, pid=PTY.spawn("ssh orthrus@#{ARGV[0]}") 
  reader.expect(/^.*password:/)
  writer.puts("cisco123\r")
  reader.expect(/^Orthrus-sip\#/)
  writer.puts("dbg\r")
  reader.expect('>')
  writer.puts("switch MXP\r")
  reader.expect('MXP>MXP>')
  writer.puts("sa pcu show-server\r\r")
  reader.expect('MXP>')
  #answer = reader.gets
  #puts "\n\nAnswer = #{answer}"
  
#end
#spawnSSH

	
