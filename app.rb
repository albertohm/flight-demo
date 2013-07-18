
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
  set :neo, Proc.new {development? ? (Neography::Rest.new) : Neography::Rest.new(ENV['NEO4J_URL'])}
  set :bind, '0.0.0.0'
end

get '/' do
  haml :index, :format => :html5
end

get '/application.js' do
  content_type "text/javascript"
  coffee :application
end

get '/api/v1/prepare_selects' do
  query = "START n=node:node_auto_index(type='Airport')
    RETURN n.name as Name, n.country as Country, n.iata_faa as Code;"
  result = settings.neo.execute_query(query)
  response = {:result => result}
  json response
end

post '/api/v1/search_airports' do
  query = "START from_air=node:node_auto_index(name={from}),
  to_air=node:node_auto_index(name={to})
  MATCH  p=(from_air)-[:VIA|TO*2..4]->(to_air)
  WITH (length(rels(p))/2-1) AS Stops, from_air, to_air, FILTER(x in p: has(x.airline)) as raw_routes,
  FILTER(x in TAIL(p): has(x.name)) AS raw_airports
  RETURN from_air.name AS From, extract(n in raw_airports : n.name) as Airports,
  extract(n in raw_routes : n.airline) as Route,
  to_air.name AS To, Stops ORDER BY Stops LIMIT 50;"
  result = settings.neo.execute_query(query, {from: params[:from], to: params[:to]})
  response = {:result => result}
  json response
end
