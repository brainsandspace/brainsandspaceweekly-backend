# app.rb
require 'sinatra'
require_relative './cabinets/cabinets.rb'

# example
get '/cabinets' do
  return get_reviews
end
# then in the client: 
# fetch(69.164.222.13).then(data => data.json()).then(readable => console.log(readable))

get '/frank-says' do
  'Put this in your pipe & smoke it'
end
