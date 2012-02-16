require_relative "platform"

module Semilla

	def self.run_player(flashbin, swf)
	
		command = ""
	
		if is_mac?
			command = "open -a \"#{flashbin}\" \"#{swf}\""
		else
			command = "\"#{flashbin}\" \"#{swf}\""
		end
		
		puts command
		
		return %x[#{command}]
	
	end

end