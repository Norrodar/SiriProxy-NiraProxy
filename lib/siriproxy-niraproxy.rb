#Encoding: UTF-8

require 'cora'
require 'siri_objects'
require 'open-uri'
require 'url_escape'

class SiriProxy::Plugin::NiraProxy < SiriProxy::Plugin
	
	def initialize (config)
		##-> Constructor
		 #-------------------------------------------------------------------------------->
		 #-> Additional configurations
		 #-<
	end


	def process (text)
 		##-> SiriProxy-Identification
 		 #-------------------------------------------------------------------------------->
 		 #-> Feel free to register on my great Niranda.net (http://www.Niranda.net) to get
 		 #-> special configurations for our API-Access. It's free.
 		 #-> Visit http://proxy.niranda.net for more information.
 		 #-< 
 		 
 		##-> Parameter-Usage
 		 #-------------------------------------------------------------------------------->
 		 #-> id		= your Identity
 		 #-> key	= your personal (preshared) key
 		 #-< 
 		 
 		uri = "http://proxy.niranda.net/siri.php?id=default&key=default&inquiry="	# URI to NiraProxy-API
 		
 		
 		uri << URLEscape.escape(text)												# Add HTMLized inquiry
 		answer = ""																	# define default answer
 		
 		open (uri) {																# execute the inquiry
			|f|
			answer = f.read															# get the great answer
 		}
 		
 		
 		##-> Answer-Check
 		 #-------------------------------------------------------------------------------->
 		 #-> If "%noanswer%" is given back, SiriProxy will ask the Apple-Servers
 		 #-<
 		 
 		if (answer =~ /%noanswer%/i)
			success = false														# well, ask Apple...
 		else
			success = true															# don't ask Apple!
 		end
 		
 		if (success)																# on success...
			say answer																# ansering...
			request_completed														# finish this cool script...
 		end
 		
 		return success																# success or no success? Return it! 
	end
end
