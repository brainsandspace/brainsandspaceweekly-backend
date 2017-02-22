#!/usr/bin/env ruby
require 'capybara'
require 'capybara/poltergeist'
require 'capybara/dsl'

require 'json'
require 'uri'
require 'pp'

require_relative 'constants.rb'

# throws a warning but w/e
include Capybara::DSL

# pp Capybara::Poltergeist

Capybara.configure do |config|
  config.run_server = false
  config.default_driver = :poltergeist
  config.app_host = 'https://www.google.com' # change url
end

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, { js_errors: false })
end


cabinets_hash = {}
# scrape amazon pages for images and text
CABINET_PAGE_LINKS.each_with_index do |link, ind|
  page = visit link
  # puts page.body

  sleep 5

  page_hash = {}

  # puts 'beginning wait'
  # wait_until do 
  #   page.has_selector?('#leftCol')
  # end
  # puts 'the wait is over'

  # if page.body.match(/data\["colorImages"\] = (\{.+\]\}\}\]\})/)
  #   images_json = page.body.match(/data\["colorImages"\] = (\{.+\]\}\}\]\})/).captures
  # elsif page.body.match(/data\['colorImages'\] = (\{.+\]\}\}\]\})/)
  #   images_json = page.body.match(/data\['colorImages'\] = (\{.+\]\}\}\]\})/).captures
  # elsif page.body.match(/'colorImages'/)
  #   images_json = page.body.match(/'colorImages': (\{ 'initial'.+\}\]\}),/).captures
  # end

  # landing image is the main big image you see
  page_hash[:landing_image] = { 
    src: page.has_selector?('#landingImage') ? page.find_by_id('landingImage')[:src] : nil,
    alt: page.has_selector?('#landingImage') ? page.find_by_id('landingImage')[:alt] : nil
  }

  pp page.body
  File.write('./cabinets/output', page.body)

  page.find('#leftCol')
  # thumbnail images for image gallery
  # if page.has_selector?('#leftCol')
    page.within("#leftCol") do
      page.has_selector?('#altImages') ?
        page.within("#altImages") do
          page_hash[:image_thumbs] = []
          page.all('img').each do |img|
            page_hash[:image_thumbs].push({ 
              src: img[:src],
              alt: img[:alt]
            })
          end
        end :
        nil
      end
  # end

  # brand name is displayed right above product title
  page_hash[:brand] = page.has_selector?('#brand') ? page.find_by_id('brand').text : nil
  page_hash[:title] = page.has_selector?('#title') ? page.find_by_id('title').text : nil
  page_hash[:price] = page.has_selector?('#price') ? page.find_by_id('priceblock_ourprice').text : nil

  # In stock, out of stock 
  # if page.has_selector?('#availability')
    page.within('#availability') do 
      page_hash[:availability] = page.find('span').text
    end
  # end
  
  # main features
  # if page.has_selector?('#feature-bullets')
    page.within('#feature-bullets') do 
      page_hash[:feature_bullets] = []
      page.all('li').each do |bullet|
        page_hash[:feature_bullets].push(bullet.text)
      end
    end
  # end

  # product description
  # if page.has_selector?('#productDescription')
    page.within('#productDescription') do
      page_hash[:product_description] = page.find('p').text
    end
  # end

  # things like weight and dimensions
  # page.has_selector?('#productDetails_techSpec_section_1') ?
    page.within('#productDetails_techSpec_section_1') do 
      page.within('tbody') do
        page_hash[:product_details] = {
          headings: [],
          data: [],
        }
        page.all('th').each do |th|
          page_hash[:product_details][:headings].push(th.text)
        end
        page.all('td').each do |td|
          page_hash[:product_details][:data].push(td.text)
        end
      end
    end 
    # :
  # nil
 
  # pp page_hash
  cabinets_hash[CABINET_MEMBERS[ind].tr(' ', '_')] = page_hash
end

File.write('./cabinets/cabinet_pages.json', cabinets_hash.to_json)

