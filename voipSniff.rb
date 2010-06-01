=begin
Program:voipSniff.rb
Author: Lee 2010.05.06 
=end
tsharkCmdFile='sharkOrthrus.sh'



#External File
require 'ConsUtil.rb'
include Cc

if ARGV[0]==nil 
	puts "Usage: ruby voipSniff.rb [MAC Address|IP Address] \n\n"
    Process.exit
end
if ARGV[0].split('.').length ==4
		oMac=`sh findMac.sh #{ARGV[0]}`
		$targetMac=oMac.split(' ')[3]
elsif ARGV[0].split(':').length ==6
		$targetMac=ARGV[0]
else
	puts "Usage: ruby voipSniff.rb [MAC Address|IP Address] \n\n"
    Process.exit
end
$fCmd=open(tsharkCmdFile,'r')
cmd=""
while $fCmd.gets
	cmd+=$_
end
$fCmd.close
#cmd=cmd.gsub('EC:44:76:1F:7E:62',ARGV[0])
cmd=cmd.gsub('EC:44:76:1F:7E:62',$targetMac)
require 'pty'
$f,$w,pid=PTY.spawn(cmd)
def sysTimeWrap (content)
   t=Time.new
   return Cc.cTrivial(t.strftime("(#{$targetMac[-5..-1].upcase})%H:%M:%S"))+"\t"+content.to_s
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

$shrHash={} #counter hash
def packetShrink(mNotify,setShrink=500,key="NONE") #convert 'cShrink' the same packet to 1
	if !$shrHash.has_key?(key)
        $shrHash[key]=0
    end
   	if $shrHash[key] > setShrink
   	  putLine(sysTimeWrap(Cc.cTrivial(mNotify)))
      $shrHash[key]=0
    else
      $shrHash[key]+=1
    end
end
  loop{
    answer = $f.gets
	case answer
    when /NOTIFY sip.* \(text\/plain\)/
       putLine(sysTimeWrap("CUCM send #{Cc.cEvent("Reset or Restart")}"))
    when /CDP Device ID: (\S+)/
       putLine(sysTimeWrap(lastArrWrap("#{Cc.cTrivial("CDP  device ID is #{$1}")}","cdp")))
   # when /ARP Who has (\S+)?/
   #    putLine("#{sysTime}\t #{cTrivial("ARP: who? #{$1}")}")
   # when /ARP (\S+) is at (\S+)/
   #    printLine(cTrivial(".. is ")+$2)
   # when /SIP Request: REGISTER sip:(\S+)[\s.|;\S+](?!sip.Reason) sip.Expires/
   #    putLine(sysTimeWrap(lastArrWrap(Cc.cTrivial("SIP  keepAlive #{$1.split(';')[0]}"),"sip"+$1)))
    when /Request: INVITE sip:(\S+):/
       putLine(sysTimeWrap("INVITE #{$1}"))
    when /SIP Request: REGISTER sip:(\S+)[;|\s].* sip.Reason/
       putLine(sysTimeWrap(Cc.cEvent("SIP")+Cc.cTrivial("  register ")+$1.split(';')[0]))
    #when /SIP Request: REFER sip:(\S+) /
    #   printLine(Cc.cEvent(" ..REFER ")+$1)
    when /Request: BYE sip/
       putLine(sysTimeWrap("BYE a call"))
    when /DHCP Request/
       putLine(sysTimeWrap(lastArrWrap(Cc.cTrivial("DHCP Request"),"dhcp")))
    when /DHCP ACK/
       printLine(cTrivial("..obtained ACK"))
    when /Gratuitous ARP for (.*) /
       putLine(sysTimeWrap(lastArrWrap(Cc.cTrivial("GARP for #{$1}"),"garp")))
    when /-> (\S+) DNS Standard query A (\S+)/
       putLine(sysTimeWrap(lastArrWrap("#{Cc.cEvent("DNS")}  query for #{$2} from "+$1,"dns"+$1)))
    when /DNS Standard query response A (\S+)/
       printLine(cMag(".. response "+$1))
    when /DNS Standard query response, No such name/
       printLine(cEvent(".. response No such name"))
    when /-> (\S+) TFTP Read Request, File: (\S+)\\/
       putLine(sysTimeWrap("#{Cc.cEvent("TFTP")} request #{Cc.cFileName("#{$2}")} from "+$1))
    when /PT=ITU-T G.711/
		packetShrink("G.711 RTP...sending",500,"g711")
    when /(\S+) -> (\S+) RTP EVENT Payload type=RTP Event, (.*) \(end\)/
		putLine("\t\t"+Cc.cTrivial("#{$3} (#{$1})"))
    when /PT=ITU-T G.729/
		packetShrink("G.729 RTP...sending",500,"g729")
    when /UDP Source port/
		packetShrink("UDP...sending",500,"udp")
    when /TFTP Data Packet.*\(last\)/
       printLine(Cc.cMag(".. obtained"))
    when /TFTP Error Code.*Could not open/
       printLine(Cc.cRed(".. failed!"))
    #when /HTTP GET \/(\S+)/
	#   putLine(sysTimeWrap("HTTP #{Cc.cTrivial("sent #{$1}")}"))
    when /SIP Status: 401 Unauthorized/
	   putLine(sysTimeWrap(lastArrWrap("SIP #{Cc.cTrivial("Unauthorized")}","Unauth")))
    when /(\S+) -> \S+ RTP PT=Comfort noise/
	   packetShrink("Comfort noise (#{$1})",20,"VND")
    when /T.38 UDP:UDPTLPacket/
		packetShrink("T.38 fax...sending",500,"t38")
    when /TLSv1/
		packetShrink("TLS..",20,"tls")
    when /(\S+) -> (\S+) DHCP DHCP Release/
        putLine(sysTimeWrap(Cc.cEvent("DHCP")+Cc.cTrivial(" release(")+$1+Cc.cTrivial(")")))
    end

  }


