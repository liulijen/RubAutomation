require 'nokogiri'
require'net/http'  
url="http://#{ARGV[0]}/Device_Information.htm"  
url2="http://#{ARGV[0]}/Network_Setup.htm"  
listed=Array.new
listed.push("MAC Address","Phone 1 DN","Status1","Phone 2 DN","Status2","Call Manager 1","Call Manager 2","Call Manager 3","Call Manager 4","Call Manager 5","Security 1 Mode","Security 2 Mode","SW_Version ID","Time","Date"); #Specified Show Column

puts "\n\n\n===========Getting #{ARGV[0]} Web Page==========\n\n"
url=URI.parse(url)   
url2=URI.parse(url2)   
Net::HTTP.start(url.host) do |http|   
    req=Net::HTTP::Get.new(url.path)   
    req.basic_auth "supervisor","12345"  
    resp=http.request(req)   
    #print resp.code,resp.body   
        i=0;
    Nokogiri::HTML(resp.body).xpath("//tr/td/p/b[not (span) and not (a)]/text()").each{|match|
        match=match.to_s.gsub("\n","")
        if i==0
           if listed.include?(match)
			  print match          
              print "\t"           
              i=1
              listed.delete(match)
           end
        else
           print match
           print "\n"           
           i=0
        end
    }
    req=Net::HTTP::Get.new(url2.path)   
    req.basic_auth "supervisor","12345"  
    resp=http.request(req)   
    #print resp.code,resp.body   
        i=0;
    Nokogiri::HTML(resp.body).xpath("//tr/td/p/b[not (span) and not (a)]").each{|match|
        match=match.to_s.gsub("<b>","").gsub("</b>","")
        if i==0
           if listed.include?(match)
		      print match
	 	      print "\t"           
			  i=1
           end
        else
           print match
           print "\n"           
           i=0
        end
    }
end  

puts "\n============Getting End==============" 
=begin
Nokogiri::HTML(open("http://supervisor:12345@#{ARGV[0]}")).xpath("//body").each{|mat|
    puts mat
}
=end

