
require 'rubygems'
require 'bundler/setup'
require 'sinatra'
require './src/app'

run Sinatra::Application.run!