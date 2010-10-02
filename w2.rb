#! /usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'lib/w2/helpers'
require 'lib/w2/controller'
helpers do
  include W2::Helpers
end
extend W2::Controller
