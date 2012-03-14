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
		 
		 @config = config															# Load config-parameters
	end


	def process (text)
 		##-> SiriProxy-Identification
 		 #-------------------------------------------------------------------------------->
 		 #-> Feel free to register on my great Niranda.net (http://www.Niranda.net) to get
 		 #-> special configurations for our API-Access. It's free.
 		 #-> Visit http://proxy.niranda.net for more information.
 		 #->
 		 ##-> Attention
 		 #-> Do not change the following lines. This are requirements for the NiraProxy.
 		 #-< 
 		 
 		np_version = "0.1.0"														# compatible NiraProxy Web-Version
 		answer = ""																	# default answer
 		success = false																# default answer-status (ask Apple...)
 		
 		
 		##-> Parameter-Usage
 		 #-------------------------------------------------------------------------------->
 		 #-> If you like to change something, use the config-file (/.SiriProxy/config.yml)
 		 #->
 		 ##-> Parameter-Description 
 		 #-> id				your Identity (should be escaped)
 		 #-> key			your personal key (should be escaped)
 		 #-> inquiry		spoken inquiry (should be escaped)
 		 #-< 
 		 
 		uri_server = "http://proxy.niranda.net"										# Server
 		uri_script = "/siri/siri.php"												# Path to script
 		uri_id = URLEscape.escape(@config['user_id'])								# User-ID
 		uri_key = URLEscape.escape(@config['user_secret'])							# User-Secret
 		uri_inquiry = URLEscape.escape(text)										# Innquiry
 		
 		uri = uri_server + uri_script + "?v=" + np_version + "&id=" + uri_id + "&key=" + uri_key + "&inquiry=" + uri_inquiry

 		
 		##-> Send the inquiry and catch the answer
 		 #-------------------------------------------------------------------------------->
 		 #-> Just read out the given URI
 		 #-<
 		
 		open (uri) {																# execute the inquiry
			|f|
			answer = f.read															# get the great answer
 		}
 		
 		
 		##-> Answer-Check
 		 #-------------------------------------------------------------------------------->
 		 #-> Processing the answer and choose the type of return
 		 #->
 		 ##-> Parameter-Description
 		 #-> %noanswer%		no answer, ask apple
 		 #-> %nirasplit%	splitter for seperat array-elements
 		 #-> %type-say%		say sth.
 		 #-> %type-ask%		ask sth.
 		 #-> %type-show%	show sth. (Wolfram Alpha Frame)
 		 #->
 		 ##-> Fallback
 		 #-> %update%		no answer, ask apple and remind to update
 		 #-<
 		 
 		# Nachricht splitten
 		answer_parts = answer.split('%nirasplit%')
 		answer_type = answer_parts.shift											# select answer-type, rest is the answer itself
 		 
 		if (answer_type =~ /%noanswer%/i)											# well, ask Apple...
			success = false
		
		elsif (answer_type =~ /%update%/)											# Plugin-Version is to old, update
			if (@config["remind_on_update"])
				answer_parts.each do |textline|
					say textline
				end
				
				success = true
				request_completed
			
			else			
				success = false
			end
														
 		elsif (answer_type =~ /%type-ask%/i)										# question with options
			# this functionallity is still in dev
			success = false
 		
 		elsif (answer_type =~ /%type-show%/i)										# sth to show
 			answer_headline = answer_parts.shift
 			
			object = SiriAddViews.new
    		
    		answer_show = SiriAnswer.new(answer_headline, [
    			answer_parts.each do |textline|
					SiriAnswerLine.new(textline)
				end
    		])
    		
    		object.views << SiriAnswerSnippet.new([answer_show])
    		send_object object
			
			success = true
			request_completed
			
		elsif (answer_type =~ /%type-say%/i)										# say it
			answer_parts.each do |textline|
				say textline
			end
			
			success = true
			request_completed
			
		
		else																		# fallback, just say it...
			answer_parts.each do |textline|
				say textline
			end
			
			success = true
			request_completed											
 		
 		end
 		
 		
 		#if (success)																# on success...
		#	say answer																# ansering...
		#	request_completed														# finish this cool script...
 		#end
 		
 		return success																# success or not? Return it! 
	end
end
