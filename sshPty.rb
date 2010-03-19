require 'pty'
require 'expect'

$expect_verbose = true
@account = 'orthrus'
@password = 'cisco123'
def showServer 
  reader, writer, pid=PTY.spawn("ssh #{@account}@#{ARGV[0]}") 
  reader.expect(/^.*password:/)
  writer.puts("#{@password}\r")
  reader.expect(/^Orthrus-sip\#/)
  writer.puts("dbg\r")
  reader.expect('>')
  writer.puts("switch MXP\r")
  writer.puts("sa pcu show-server\r")

  reader.expect('2010')
  writer.puts('\r\r')
  5.times{
    answer = reader.gets
    puts "#{answer}"
  }
end
def showSWversion 
  reader, writer, pid=PTY.spawn("ssh #{@account}@#{ARGV[0]}") 
  reader.expect(/^.*password:/)
  writer.puts("#{@password}\r")
  reader.expect(/^Orthrus-sip\#/)
  writer.puts("dbg\r")
  reader.expect('>')
  writer.puts("switch SHELL\r")
  reader.expect('~ #')
  writer.puts("cat /etc/versions\r")
  
  7.times{
    answer = reader.gets
    puts "#{answer}"
  }
end
def showLSCkey 
  reader, writer, pid=PTY.spawn("ssh #{@account}@#{ARGV[0]}") 
  reader.expect(/^.*password:/)
  writer.puts("#{@password}\r")
  reader.expect(/^Orthrus-sip\#/)
  writer.puts("dbg\r")
  reader.expect('>')
  writer.puts("switch SHELL\r")
  reader.expect('~ #')
  writer.puts("ls /var/voice_conf/sec1/lsc0\r")
  writer.puts("ls /var/voice_conf/sec2/lsc0\r")
  6.times{
    answer = reader.gets
    puts "#{answer}"
  }

 
end
case ARGV[1]
  when '1' then
    showServer
  when '2' then
    showSWversion
  when '3' then
    showLSCkey
  else
    puts "No Input" 
end		 
