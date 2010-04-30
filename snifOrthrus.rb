$expect_verbose = true
if ARGV[0].length!=17
	puts "Usage: snifOrthrus [MAC Address]\n\n"
    Process.exit
end
$fCmd=open('sharkOrthrus.sh','r')
cmd=""
while $fCmd.gets
	cmd+=$_
end
$fCmd.close
cmd=cmd.gsub('EC:44:76:1F:7E:62',ARGV[0])
#$f=IO.popen 'tshark -i en0 -f "ether host EC:44:76:1F:7E:62 and not udp" -V'
require 'pty'
$f,$w,pid=PTY.spawn(cmd)
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
def cRed(ori)
   return "\33[1;31;40m#{ori}\33[0m"
end
def sysTime
   t=Time.new
   return cTrivial(t.strftime("(#{ARGV[0][-5..-1]})%H:%M:%S"))
end
def putLine(text)
	print "\n"+text
end
def printLine(text)
    print text
end
trap("INT") { 
	puts "#{cTrivial("User stop analyzing!")}"
    Process.exit
}
  printLine("Capturing..")
  cRTP=0; #RTP show interval
  tCDP=0; #CDP timer
  loop{
    #$f.sync 
    answer = $f.gets
    #$f.flush
    #puts answer
	case answer
    when /NOTIFY sip.* \(text\/plain\)/
       putLine("#{sysTime} CUCM send #{cEvent("Reset or Restart")}")
    when /CDP Device ID: (\S+)/
       putLine("#{sysTime}\t #{cTrivial("CDP: device ID is #{$1}")}")
    when /ARP Who has (\S+)?/
       putLine("#{sysTime}\t #{cTrivial("ARP: who? #{$1}")}")
    when /ARP (\S+) is at (\S+)/
       printLine(cTrivial(".. is ")+$2)
    when /Request: INVITE sip/
       putLine("#{sysTime}\t INVITE a call")
    when /Request: BYE sip/
       putLine("#{sysTime}\t BYE a call")
    when /DHCP Request/
       putLine("#{sysTime}\t #{cTrivial("DHCP Request")}")
    when /DHCP ACK/
       putLine("#{sysTime}\t #{cTrivial("DHCP ACK")}")
    when /Gratuitous ARP for (.*) /
       #puts "#{sysTime}\t #{cEvent("GARP")} for #{$1}"
       putLine("#{sysTime}\t #{cTrivial("GARP for #{$1}")}")
    when /-> (\S+) DNS Standard query A (\S+)/
       putLine("#{sysTime}\t #{cEvent("DNS")}  query for #{$2} from "+$1+"")
    when /DNS Standard query response A (\S+)/
       printLine(cEvent(".. response "+$1))
    when /-> (\S+) TFTP Read Request, File: (\S+)\\/
       putLine("#{sysTime}\t #{cEvent("TFTP")} request #{cFileName("#{$2}")} from "+$1)
    when /PT=ITU-T G.711/
       if cRTP>500
       	  putLine("#{sysTime}\t #{cTrivial("G.711 RTP...sending")}")
          cRTP=0
       else
          cRTP+=1
	   end
    when /PT=ITU-T G.729/
       if cRTP>500
       	  putLine("#{sysTime}\t #{cTrivial("G.729 RTP...sending")}")
          cRTP=0
       else
          cRTP+=1
	   end
    when /TFTP Data Packet.*\(last\)/
       printLine(cEvent(".. obtained"))
    when /TFTP Error Code.*Could not open/
       printLine(cRed(".. failed!"))
    when /HTTP GET \/(\S+)/
	   putLine("#{sysTime}\t HTTP #{cTrivial("sent #{$1}")}")
    end
  }


