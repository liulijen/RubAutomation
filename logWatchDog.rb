$expect_verbose = true
def sysTime
   t=Time.new
   return t.strftime("#{ARGV[0]} %H:%M:%S")
end
fName=Time.new.strftime("#{ARGV[0].split('.')[3]}.%Y%m%d_%H-%M-%S")
@account = 'orthrus'
@password = 'cisco123'
@logTmpFile="logs/#{fName}.log"

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
  @log=File.open(@logTmpFile,'w')
  loop{ 
    answer = reader.gets
    @log.write(answer)
	case answer
    when /IPPS_MFMT_RTVAVP_ID/
       puts "#{sysTime}\tRTP started"
    when /IPPS_MFMT_RTVSAVP_ID/
       puts "#{sysTime}\tSRTP started"
    when /EVT_DNLD_FILE_TRYING/
       puts "#{sysTime}\tObtain a file"
    when /update common cfg/
       puts "#{sysTime}\tUsing download file"
    when /applySavedCfgFile/
       puts "#{sysTime}\tUsing saved file"
    when /Destroying.../
       puts "#{sysTime} Software Reset"
    when /Press ESC for monitor/
       puts "#{sysTime} Hardware Reset"
    when /Assert/
       puts "#{sysTime}\t\t\tAssertion Happened!!!!!!!!!!"
    when /ready to close/
       puts "#{sysTime}\t\t\tCrash!!!!!!!!!!"
    when /System restart caused by vlan/
       puts "#{sysTime}\t\tSystem restart caused by vlan"
    when /Ambiguous/
       puts "#{sysTime} Ambiguous: might be UDP and TCP problem"
    when /private key is null/
       puts "#{sysTime} private key is null."
    end
  }
