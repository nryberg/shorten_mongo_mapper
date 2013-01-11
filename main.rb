require 'rubygems'
require 'sinatra'
require 'uri'
require 'yaml'
require 'mongo_mapper'


configure do
  #mongodb://<user>:<password>@linus.mongohq.com:10031/shorten
  MongoMapper.connection = Mongo::Connection.new('linus.mongohq.com', 10031)
  MongoMapper.database = 'shorten'
  MongoMapper.database.authenticate('shortened', 'Rwt6X9xWzsTFbNtJG')

	require 'ostruct'
	#	:base_url => "http://localhost:4567/",
	Shorten = OpenStruct.new(
		:base_url => "http://radiant-castle-2552.herokuapp.com/",
		:service_name => "shrt.en",
		:button_text => "shorten",
		:path_size => 4
	)
	
	$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')
	
end

$LOAD_PATH.unshift(File.dirname(__FILE__) + '/lib')

require 'shortenurl'

helpers do
	def validate_link(link)
		halt 401, 'We do not accept local URLs to be shortened' unless valid_url? link
	end
	
	# Determine if a URL is valid.  We run it through 
	def valid_url?(url)
		if url.include? "%3A"
			url = URI.unescape(url)
		end

		retval = true
		
		begin
			uri = URI.parse(URI.escape(url))
			if uri.class != URI::HTTP and uri.class != URI::HTTPS
				retval = false
			end
			
			host = (URI.split(url))[2]
			if host =~ /^(localhost|192\.168\.\d{1,3}\.\d{1,3}|127\.0\.0\.1|172\.((1[6-9])|(2[0-9])|(3[0-1])).\d{1,3}\.\d{1,3}|10.\d{1,3}\.\d{1,3}.\d{1,3})/
				retval = false
			end
		rescue URI::InvalidURIError
				retval = false
		end
		
		retval
	end
end 

get '/' do
	erb :index
end

get '/new' do
	erb :new, :locals => { :type => "main" }
end

get %r(/(api-){0,1}create/(.*)) do |api, link|
	validate_link link

	url = ShortenUrl.create_url(link)

	if api == "api-"
		"#{url.short_url}"
	else
		erb :finished, :locals => { :url => url, :type => "finished" }
	end
end

get %r(/(api-){0,1}create) do |api|
	if request['url']
		validate_link request['url']
		url = ShortenUrl.create_url(request['url'])
		if api == "api-"
			"#{url.short_url}"
		else
			erb :finished, :locals => { :url => url, :type => "finished" }
		end
	end
end

post '/' do
	validate_link params[:url]
	url = ShortenUrl.create_url(params[:url], params[:image])
	erb :finished, :locals => { :url => url, :type => "finished", :image => params[:image] }
end


get '/recent' do
  urls = ShortenUrl.order(:created_at).reverse.limit(10)
  
  erb :recent, :locals => {:urls => urls}
end

get '/:short' do

	url = ShortenUrl.first(:key => params[:short])
  unless url.nil?
    url.increment_views
    url.save
  end
	halt 404, "Page not found" unless url
	
	if url.image == true 
	  erb :image, :locals => {:url => url}
	else
	  redirect url.url
	end

end



