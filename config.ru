require 'rubygems'
require 'bundler/setup'
require 'sequel'
require 'rack'
require 'sinatra'

require './main'

run Sinatra::Application
