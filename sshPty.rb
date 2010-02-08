require 'pty'
require 'expect'

$expect_verbose = true
PTY.spawn("ssh @") do |reader, writer, pid|
  reader.expect(/^.*password:/)
  writer.puts("\r")
  reader.expect(/^.*li88-83:~\$/)
  writer.puts("ls -l\r")
  reader.expect(/^total.*/)
  answer = reader.gets
  puts "\n\nAnswer = #{answer}"
end
