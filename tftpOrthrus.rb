require 'net/tftp'
t = Net::TFTP.new(ARGV[0])
port1="ATA"+ARGV[1].gsub(':','')+".cnf.xml.sgn"
port2="ATA"+ARGV[1].gsub(':','')[2..13]+"01.cnf.xml.sgn"
puts port2
t.getbinaryfile(port1, 'tftpTmp')
open('tftpTmp','r'){|f|
	while line=f.gets
		puts f.gets
	end 
}
t.getbinaryfile(port2, 'tftpTmp2')
open('tftpTmp2','r'){|f|
	while line=f.gets
		puts f.gets
	end 
}
