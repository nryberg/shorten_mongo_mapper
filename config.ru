require 'rubygems'
require 'bundler/setup'
#require 'sequel'
require 'rack'
require 'sinatra'
require 'mongo_mapper'

require './main'

run Sinatra::Application
