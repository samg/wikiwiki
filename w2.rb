#! /usr/bin/env ruby
require 'rubygems'
require 'sinatra'

require 'lib/w2/helpers'
helpers do
  include W2::Helpers
end

get '/style.css' do
  render :text, File.read(File.dirname) + '/public/style.css'
end

get '/app.js' do
  render :text, File.read(File.dirname) + '/public/app.js'
end

get %r'/+(.*)' do |path|
  if text = wiki_text_for(path)
    haml :show, :locals => {:path => path, :text => text}
  else 
    haml :edit, :locals => {:path => path, :text => text}
  end
end

post %r'/+(.*)' do |path|
  File.open(file_path(path), 'w') do |f|
    f.write params['wiki_text']
  end
  redirect path
end
