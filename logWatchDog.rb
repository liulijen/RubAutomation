$expect_verbose = true
def sysTime
   t=Time.new
   return t.strftime("%H:%M:%S")
end
@account = 'orthrus'
@password = 'cisco123'
require 'pty'
require 'expect'
  reader, writer, pid=PTY.spawn("ssh #{@account}@#{ARGV[0]}") 
  reader.expect(/password:/) 
  writer.puts("#{@password}\r")
  reader.expect(/(Orthrus-sip|denied)/) do |a,b|
	if b == "Orthrus-sip"
	   puts "Now watching..."
    else
       puts "Login Failed! Process Exit"
       Process.exit
    end
  end
  loop{ 
    answer = reader.gets
	case answer
    when /IPPS_MFMT_RTVAVP_ID/
       puts "#{sysTime}\tRTP started"
    when /IPPS_MFMT_RTVSAVP_ID/
       puts "#{sysTime}\tSRTP started"
    when /Destroying.../
       puts "#{sysTime} Software Reset"
    when /Press ESC for monitor/
       puts "#{sysTime} Hardware Reset"
    when /Assertion/
       puts "#{sysTime} Assertion Happened!!!!!!!!!!"
    end
   
  }
