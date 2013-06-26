
require 'rubygems'
require 'sinatra'
require 'sinatra/json'
require "sinatra/reloader" if development?
require "haml"
require "coffee_script"
require 'neography'
require "debugger" if development?

configure do
  set :public_folder, Proc.new { File.join(root, "static") }
  set :neo, Proc.new {development? ? (Neography::Rest.new) : Neography::Rest.new(ENV['NEOGRAPHY_URI'])}
  set :bind, '0.0.0.0'
end

get '/' do
  haml :index, :format => :html5
end

get '/application.js' do
  content_type "text/javascript"
  coffee :application
end

post '/api/v1/launch_cypher' do
  start = Time.now
  result = settings.neo.execute_query(params[:query])
  response = {:result => result, :time => (Time.now - start)}
  json response
end
