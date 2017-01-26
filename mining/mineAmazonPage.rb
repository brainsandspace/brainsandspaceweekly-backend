#!/usr/bin/env ruby
require 'capybara'
require 'capybara/poltergeist'
require 'capybara/dsl'

require 'uri'

require_relative 'cabinets.rb'

# throws a warning but w/e
include Capybara::DSL

Capybara.configure do |config|
  config.run_server = false
  config.default_driver = :poltergeist
  config.app_host = 'https://www.google.com' # change url
end

page = visit CABINETS[0]
# puts page.body

if page.body.match(/data\["colorImages"\] = (\{.+\]\}\}\]\})/)
  matchJSON = page.body.match(/data\["colorImages"\] = (\{.+\]\}\}\]\})/).captures
elsif page.body.match(/data\['colorImages'\] = (\{.+\]\}\}\]\})/)
  matchJSON = page.body.match(/data\['colorImages'\] = (\{.+\]\}\}\]\})/).captures
elsif page.body.match(/'colorImages'/)
  matchJSON = page.body.match(/'colorImages': (\{ 'initial'.+\}\]\}),/).captures
# # elsif page.body.match(/colorImages/)
#   matchJSON = page.body.match(/data\['colorImages'\] = (\{.+\]\}\}\]\})/).captures
#   puts "no images found for #{CABINETS[0]}"
end

if matchJSON
  File.write('./images.json', matchJSON)
else 
  File.write('./images.json', 'womp')
end  
# if page.body.match(/colorImages/)
#   matchJSON2 = page.body.match(/colorIma(ges.+\])/).captures

# end

puts matchJSON

match2 = page.body.match(/win(do)w\.amznJQ/).captures
puts match2
# puts test