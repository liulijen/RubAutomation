$expect_verbose = true
def cFileName(ori)
   return "\33[1;34;40m#{ori}\33[0m"
end
def cCriticalEvent(ori)
   return "\33[5;47;41m#{ori}\33[0m"
end
def cEvent(ori)
   return "\33[1;36;40m#{ori}\33[0m"
end
def cTrivial(ori)
   return "\33[2;47;40m#{ori}\33[0m"
end
def sysTime
   t=Time.new
   return cTrivial(t.strftime("#{ARGV[0]} %H:%M:%S"))
end

fName=Time.new.strftime("#{ARGV[0].split('.')[3]}.%Y%m%d_%H-%M-%S")
@account = 'orthrus'
@password = 'cisco123'
@logTmpFile="logs/#{fName}.log"

require 'pty'
require 'expect'
  puts "Starting.."
  reader, writer, pid=PTY.spawn("ssh #{@account}@#{ARGV[0]}") 
  reader.expect(/(password|yes)/) do |whole, match| #'yes' mains it's unknown host, need to download key
    if(match=="password")
       writer.puts("#{@password}\r")
    else
       writer.puts("yes\r")
       reader.expect(/password/)
       writer.puts("#{@password}\r")
    end
  end
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
       puts "#{sysTime}\t\t#{cTrivial("RTP started")}"
    when /Line._reg_status = 1/
       puts "#{sysTime}\t#{cEvent("Registered")}"
    when /TIU_ONHOOK.*-/
       puts "#{sysTime}\t\t#{cTrivial("On,L"+answer.split('port_id=')[1][0].chr)}"
    when /TIU_OFFHOOK.*-/
       puts "#{sysTime}\t\t#{cTrivial("Off,L"+answer.split('port_id=')[1][0].chr)}"
    when /IPPS_MFMT_RTVSAVP_ID/
       puts "#{sysTime}\tSRTP started"
    when /tftp.*69/
       puts "#{sysTime}\t\tGetting..#{cFileName(answer.split(' ')[9])}"
    when /EVT_DNLD_FILE_READY/
       puts "#{sysTime}\t\t#{cTrivial("Obtain file.")}"
    when /saveFileToFlash/
       puts "#{sysTime}\t\t#{cTrivial("File auth pass and save it to flash")}"
    when /applySavedCfgFile/
       puts "#{sysTime}\t\t#{cCriticalEvent("Loading saved file")}"
    when /REPROVISION/
       puts "#{sysTime}\t#{cEvent("Reprovision...")}"
    when /Press ESC for monitor/
       puts "#{sysTime} Hardware Reset"
    when /Assert/
       puts "#{sysTime}\t\t\t#{cCriticalEvent("Assertion Happened!!!!!!!!!!")}"
    when /ready to close/
       puts "#{sysTime}\t\t\t#{cCriticalEvent("Crash!!!")}"
    when /System restart caused by vlan/
       puts "#{sysTime}\t\t#{cCriticalEvent("System restart caused by vlan")}"
    when /Ambiguous/
       puts "#{sysTime} Ambiguous: might be UDP and TCP problem"
    when /private key is null/
       puts "#{sysTime} #{cCriticalEvent("private key is null.")}"
    end
  }
