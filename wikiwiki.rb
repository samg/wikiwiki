#! /usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'open3'
require 'haml'
require 'fileutils'
require 'diffy'
require 'will_paginate'
require File.dirname(__FILE__) + '/vendor/YAPWTP/ffi/yapwtp'
require 'lib/w2/helpers'
require 'lib/w2/controller'
helpers do
  include W2::Helpers
end
extend W2::Controller
