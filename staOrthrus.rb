require 'nokogiri'
require'net/http'
$info={}
def getRegister(ip)
	timeout(3) do
		url="http://#{ip}/Network_Setup.htm"
		url=URI.parse(url)
		Net::HTTP.start(url.host) do |http|
			req=Net::HTTP::Get.new(url.path)
			req.basic_auth "supervisor","12345"
			resp=http.request(req)
			$result=""
			Nokogiri::HTML(resp.body).xpath("//div/table/tr/td/p/b/text()").each{|ma|
				if(ma.to_s !~ /Active|Standby/) == false
					$result+=ma.to_s
				end
			}
		end
		$info[ip]=$result	
	end
	rescue Timeout::Error
		$info[ip]="timeout"
end
def collectResult
		ARGV.each{|arg|
			Thread.new{getRegister(arg)}.join
		}
end
def prResult
	fmResult=""
	$info.each{|key,value|
		fmResult+="["+key+"]\t"+value+"\n"
	}
	return fmResult
end
loop{
	collectResult
	system('clear')
	puts "-------Orthrus Register Status Real Time Monitor-------\n"
	puts prResult	
	sleep(10)
}
