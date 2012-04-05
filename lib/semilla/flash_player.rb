require_relative "platform"
require 'flashsdk'

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
	
	def self.get_player
	  #Use the flash player info found in the Environment Variable if defined.
	  return ENV['FLASH_PLAYER'] unless ENV['FLASH_PLAYER'].nil?
	  
	  #Else use the flash player provided byu Sprout
	  return Sprout::Executable.load(:flashplayer, 
                                 FlashPlayer::NAME, 
                                 FlashPlayer::VERSION).path
	end

end