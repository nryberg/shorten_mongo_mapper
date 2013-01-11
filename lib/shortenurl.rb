require 'anybase'

class ShortenUrl 
  include MongoMapper::Document

	#plugin :validation_helpers

  key :key,   String, :required => true, :unique => true
  key :url,   String, :required => true
  key :image, Boolean
  key :time,  DateTime

			
	def short_url
		"#{Shorten.base_url}#{self.key.to_s}"
	end
	
	def self.create_url(link, image = false)
 		uri = URI::parse(link)
 		raise "Invalid URL" unless uri.kind_of? URI::HTTP or uri.kind_of? URI::HTTPS

		url = self.filter(:url => link).first
		if !url 

			key = Anybase::Base62.random(Shorten.path_size)
			key_check = self.filter(:url => key).first
			
			while key_check
				key = Anybase::Base62.random(Shorten.path_size)
				key_check = self.filter(:url => key).first
			end
	
			url = self.new(:url => link, :key => key, :image => image)
			url.save					
		end
		
		url
	end
end
