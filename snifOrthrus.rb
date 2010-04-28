$expect_verbose = true
$cmd=open('sharkOrthrus.sh','r')
#$f=IO.popen 'tshark -i en0 -f "ether host EC:44:76:1F:7E:62 and not udp" -V'
require 'pty'
$f,$w,pid=PTY.spawn($cmd.gets)
#$f=IO.popen $cmd.gets 
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
trap("INT") { 
	puts "#{cTrivial("User stop analyzing!")}"
    Process.exit
}
  puts "Capturing.."
  cRTP=0; #RTP show interval
  tCDP=0; #CDP timer
  loop{
    #$f.sync 
    answer = $f.gets
    #$f.flush
    #puts answer
	case answer
    when /NOTIFY sip.* \(text\/plain\)/
       puts "#{sysTime} CUCM send #{cEvent("Reset or Restart")}"
    when /CDP Device ID: (\S+)/
       puts "#{sysTime}\t #{cTrivial("CDP: device ID is #{$1}")}"
    when /Request: INVITE sip/
       puts "#{sysTime}\t INVITE a call"
    when /Request: BYE sip/
       puts "#{sysTime}\t BYE a call"
    when /DHCP Request/
       puts "#{sysTime}\t #{cTrivial("DHCP Request")}"
    when /Gratuitous ARP for (.*) /
       #puts "#{sysTime}\t #{cEvent("GARP")} for #{$1}"
       puts "#{sysTime}\t #{cTrivial("GARP for #{$1}")}"
    when /-> (\S+) DNS Standard query A (\S+)/
       puts "#{sysTime}\t #{cEvent("DNS")} query for #{$2} from "+$1
    when /-> (\S+) TFTP Read Request, File: (\S+)\\/
       puts "#{sysTime}\t #{cEvent("TFTP")} request #{cFileName("#{$2}")} from "+$1
    when /PT=ITU-T G.711/
       if cRTP>500
       	  puts "#{sysTime}\t #{cTrivial("G.711 RTP...sending")}"
          cRTP=0
       else
          cRTP+=1
	   end
    when /PT=ITU-T G.729/
       if cRTP>500
       	  puts "#{sysTime}\t #{cTrivial("G.729 RTP...sending")}"
          cRTP=0
       else
          cRTP+=1
	   end
    when /TFTP Data Packet.*\(last\)/
       puts "#{sysTime}\t file obtained"
    when /TFTP Error Code.*Could not open/
       puts "#{sysTime}\t #{cEvent("file get failed!")}"
    end
  }


