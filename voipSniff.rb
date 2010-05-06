=begin
Program:voipSniff.rb
Author: Lee 2010.05.06 
=end
tsharkCmdFile='sharkOrthrus.sh'



#External File
require 'ConsUtil.rb'
include Cc

if ARGV[0].length!=17
	puts "Usage: snifOrthrus [MAC Address]\n\n"
    Process.exit
end
$fCmd=open(tsharkCmdFile,'r')
cmd=""
while $fCmd.gets
	cmd+=$_
end
$fCmd.close
cmd=cmd.gsub('EC:44:76:1F:7E:62',ARGV[0])
require 'pty'
$f,$w,pid=PTY.spawn(cmd)
def sysTimeWrap (content)
   t=Time.new
   return Cc.cTrivial(t.strftime("(#{ARGV[0][-5..-1]})%H:%M:%S"))+"\t"+content.to_s
end
#Time Period Meter
$last={}
def tLastArrival(key)
    if !$last.has_key?(key)
		$last[key]=Time.new.to_f
	end
	tmp=$last[key]
    $last[key]=Time.new.to_f 
    dis=($last[key]-tmp+0.5).floor
	return dis==0?-1:dis
end
def lastArrWrap(content,key)
	tmp=tLastArrival(key)
	return content+Cc.cTrivial((tmp == -1?"":" last:#{tmp}s"))
end
#Time Period Meter End
def putLine(text)
	print "\n"+text
end
def printLine(text)
    print text
end
trap("INT") { 
	puts "#{Cc.cTrivial("User stop analyzing!")}"
    Process.exit
}
  printLine("Capturing..")
$cShrink=0
def packetShrink(mNotify,setShrink=500) #convert 'cShrink' the same packet to 1
   	if $cShrink>setShrink
   	  putLine(sysTimeWrap(Cc.cTrivial(mNotify)))
      $cShrink=0
    else
      $cShrink+=1
    end
end
  loop{
    answer = $f.gets
	case answer
    when /NOTIFY sip.* \(text\/plain\)/
       putLine(sysTimeWrap("CUCM send #{Cc.cEvent("Reset or Restart")}"))
    when /CDP Device ID: (\S+)/
       putLine(sysTimeWrap(lastArrWrap("#{Cc.cTrivial("CDP: device ID is #{$1}")}","cdp")))
   # when /ARP Who has (\S+)?/
   #    putLine("#{sysTime}\t #{cTrivial("ARP: who? #{$1}")}")
   # when /ARP (\S+) is at (\S+)/
   #    printLine(cTrivial(".. is ")+$2)
    when /Request: INVITE sip:(\S+):/
       putLine(sysTimeWrap("INVITE #{$1}"))
    #when /(\S+) SIP Request: REGISTER.*sip.Expires == (\S+)/
    #   putLine(sysTimeWrap(lastArrWrap("#{cTrivial("SIP REGISTER #{$1}")}","sip")))
    #when /SIP Status: (\d+) (\S+)/
    #   printLine(cTrivial(".."+$1+" "+$2))
    when /Request: BYE sip/
       putLine(sysTimeWrap("BYE a call"))
    #when /(\S+) -> \S+ SIP Status: 200 OK/
    #   putLine(sysTimeWrap(lastArrWrap("SIP: registered (#{$1})","sip")))
    when /DHCP Request/
       putLine(sysTimeWrap(lastArrWrap(Cc.cTrivial("DHCP Request"),"dhcp")))
    when /DHCP ACK/
       printLine(cTrivial("..obtained ACK"))
    when /Gratuitous ARP for (.*) /
       #puts "#{sysTime}\t #{cEvent("GARP")} for #{$1}"
       putLine(sysTimeWrap(lastArrWrap(Cc.cTrivial("GARP for #{$1}"),"garp")))
    when /-> (\S+) DNS Standard query A (\S+)/
       putLine(sysTimeWrap(lastArrWrap("#{Cc.cEvent("DNS")}  query for #{$2} from "+$1,"dns")))
    when /DNS Standard query response A (\S+)/
       printLine(cEvent(".. response "+$1))
    when /DNS Standard query response, No such name/
       printLine(cEvent(".. response No such name"))
    when /-> (\S+) TFTP Read Request, File: (\S+)\\/
       putLine(sysTimeWrap("#{Cc.cEvent("TFTP")} request #{Cc.cFileName("#{$2}")} from "+$1))
    when /PT=ITU-T G.711/
		packetShrink("G.711 RTP...seding")
    when /PT=ITU-T G.729/
		packetShrink("G.729 RTP...sending")
    when /TFTP Data Packet.*\(last\)/
       printLine(Cc.cEvent(".. obtained"))
    when /TFTP Error Code.*Could not open/
       printLine(Cc.cRed(".. failed!"))
    when /HTTP GET \/(\S+)/
	   putLine(sysTimeWrap("HTTP #{Cc.cTrivial("sent #{$1}")}"))
    when /SIP Status: 401 Unauthorized/
	   putLine(sysTimeWrap(lastArrWrap("SIP #{Cc.cTrivial("Unauthorized")}","Unauth")))
    when /(\S+) -> \S+ RTP PT=Comfort noise/
	   packetShrink("Comfort noise (#{$1})",20)
    when /T.38 UDP:UDPTLPacket/
		packetShrink("T.38 fax...sending")
    when /TLSv1/
		packetShrink("TLS..",20)
    end

  }


