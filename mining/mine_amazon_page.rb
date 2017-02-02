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

  page_hash = {}

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

  # alternate images for image gallery
  page.within("#leftCol") do
    page.has_selector?('#altImages') ?
      page.within("#altImages") do
        page_hash[:alt_images] = []
        page.all('img').each do |img|
          page_hash[:alt_images].push({ 
            src: img[:src],
            alt: img[:alt]
          })
        end
      end :
      nil
  end

  # brand name is displayed right above product title
  page_hash[:brand] = page.find_by_id('brand').text
  page_hash[:title] = page.find_by_id('title').text
  page_hash[:price] = page.find_by_id('priceblock_ourprice').text

  # In stock, out of stock 
  page.within('#availability') do 
    page_hash[:availability] = page.find('span').text
  end
  
  # main features
  page.within('#feature-bullets') do 
    page_hash[:feature_bullets] = []
    page.all('li').each do |bullet|
      page_hash[:feature_bullets].push(bullet.text)
    end
  end

  # product description
  page.within('#productDescription') do
    page_hash[:product_description] = page.find('p').text
  end

  # things like weight and dimensions
  page.has_selector?('#productDetails_techSpec_section_1') ?
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
    end :
  nil
 
  # pp page_hash
  cabinets_hash[CABINET_MEMBERS[ind].tr(' ', '_')] = page_hash
end

File.write('./cabinets/cabinet_pages.json', cabinets_hash.to_json)

