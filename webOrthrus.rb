require 'nokogiri'
require'net/http'  
url="http://#{ARGV[0]}/Device_Information.htm"  
url2="http://#{ARGV[0]}/Network_Setup.htm"  
url=URI.parse(url)   
url2=URI.parse(url2)   
Net::HTTP.start(url.host) do |http|   
    req=Net::HTTP::Get.new(url.path)   
    req.basic_auth "supervisor","12345"  
    resp=http.request(req)   
    #print resp.code,resp.body   
        i=0;
    Nokogiri::HTML(resp.body).xpath("//tr/td/p/b[not (span) and not (a)]/text()").each{|match|
        print match
        if i==0
           print "\t"           
           i=1
        else
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
        print match.to_s.gsub("<b>","").gsub("</b>","")
        if i==0
           print "\t"           
           i=1
        else
           print "\n"           
           i=0
        end
    }
end  

=begin
Nokogiri::HTML(open("http://supervisor:12345@#{ARGV[0]}")).xpath("//body").each{|mat|
    puts mat
}
=end
