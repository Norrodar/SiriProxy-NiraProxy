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
 		 
 		np_version = "0.5.0"														# PlugIn Version (Out-Of-Date may not run...)
 		np_updatereminder = @config['remind_on_update']
 		np_lang = @config['language']
 		answer = ""																	# default answer
 		success = false																# default answer-status (ask Apple...)
 		
 		
 		##-> Parameter-Usage
 		 #-------------------------------------------------------------------------------->
 		 #-> If you like to change something use the config-file (.../.SiriProxy/config.yml)
 		 #->
 		 ##-> Parameter-Description 
 		 #-> id				your Identity (should be escaped)
 		 #-> key			your personal key (should be escaped)
 		 #-> inquiry		spoken inquiry (should be escaped)
 		 #-< 
 		 
 		uri_server = "http://siri.niranda.net"										# Server
 		uri_script = "/api.php"														# Path to script
 		uri_id = URLEscape.escape(@config['siriproxy_id'])							# User-ID
 		uri_key = URLEscape.escape(@config['siriproxy_secret'])						# User-Secret
 		uri_inquiry = URLEscape.escape(text)										# Innquiry
 		#uri_id = "hello"
		
 		uri = uri_server + uri_script + "?v=" + np_version + "&vr=" + np_updatereminder +"&id=" + uri_id + "&key=" + uri_key + "&inquiry=" + uri_inquiry

 		
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
 		 #-> %type-pic%		show a picture
 		 #->
 		 ##-> Fallback
 		 #-> %update%		no answer, ask apple and remind to update
 		 #-<
 		 
 		# Split the message
 		answer_parts = answer.split('%nirasplit%')
 		answer_type = answer_parts.shift											# select answer-type, rest is the answer itself
 		
 		
 		##-> No answer
 		 #-> Now ask Apple
 		if (answer_type =~ /%noanswer%/i)											# well, ask Apple...
			success = false
		
		
		##-> Update
		 #-> You have to update the NiraProxy-Plugin for SiriProxy
		elsif (answer_type =~ /%update%/)											# Plugin-Version is to old, update
			if (np_lang =~ /de-de/i)
 				say "NiraProxy hat ein Update erfahren. Das SiriProxy-Plugin ist nun veraltet. Ein zuverlässiger Betrieb kann nicht mehr garantiert werden."
 			
 			elsif (np_lang =~ /en-us/i)
 				say "NiraProxy get a new version. The SiriProxy-Plugin is out of date. The reliable operation can not be guaranteed."
 				
 			else
 				say "NiraProxy get a new version. The SiriProxy-Plugin is out of date. The reliable operation can not be guaranteed."
 			end
			
			success = true
			request_completed
		
		
		##-> Question / Ask
		 #-> Siri ask sth. and like to get an answer from you						
 		elsif (answer_type =~ /%type-ask%/i)										# question with options
			# this functionallity is still in dev
			
			success = false
 		
 		
 		##-> Picture / Image
 		 #-> Siri post a picture
 		elsif (answer_type =~ /%type-pic%/i)										# question with options
			answer_headline = answer_parts.shift									# Get headline (first place)
 			picurl = answer_parts.shift
 			
 			if (np_lang =~ /de-de/i)
 				say "Ich lade das Bild..."
 			
 			elsif (np_lang =~ /en-us/i)
 				say "I'll load the picture..."
 				
 			else
 				say "I'll load the picture..."
 			end
 			
			object = SiriAddViews.new												# Start showing
    		
    		answer_show = SiriAnswer.new(answer_headline, [
    			SiriAnswerLine.new(answer_headline, picurl)
    		])
			
    		object.views << SiriAnswerSnippet.new([answer_show])					# push all to the phone
    		send_object object
			
			success = true
			request_completed
 		
 		
 		##-> Show
 		 #-> Just show a list without speaking
 		elsif (answer_type =~ /%type-show%/i)										# show something...
 			answer_headline = answer_parts.shift									# Get headline (first place)
 			
 			lines = ""																# Build answers
 			answer_parts.each do |textline|
				lines = lines + textline + "\n"
			end
 			
 			
			object = SiriAddViews.new												# Start showing
    		
    		answer_show = SiriAnswer.new(answer_headline, [
    			SiriAnswerLine.new(lines)
    		])
			
    		object.views << SiriAnswerSnippet.new([answer_show])					# push all to the phone
    		send_object object
			
			success = true
			request_completed
		
		
		##-> Say
		 #-> Siri can talk :)
		elsif (answer_type =~ /%type-say%/i)										# say it
			answer_parts.each do |textline|
				say textline
			end
			
			success = true
			request_completed
			
		
		##-> Fallback
		 #-> If nothing match Siri will read it out
		else																		# fallback, just say it...
			answer_parts.each do |textline|
				say textline
			end
			
			success = true
			request_completed											
 		
 		end
 		
 		
 		##-> Finish it!
 		 #-> All fine?
 		 #-> False	-> Send it to Apple
 		 #-> True	-> I have an answer!
 		return success																# success or not? Return it! 
	end
end
