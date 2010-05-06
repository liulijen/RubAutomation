module Cc
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
end

