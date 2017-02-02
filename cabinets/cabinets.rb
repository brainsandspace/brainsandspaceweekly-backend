require 'twitter'
require 'firebase'
require 'pp'

require_relative '../secrets.ignore.rb'
include Secrets 

TEN_MINUTES = 600000 # 10 minutes in ms
CABINET_MEMBERS = [
  "Rex Tillerson",
  "Steve Mnuchin",
  "James Mattis",
  "Jeff Sessions",
  "Ryan Zinke",
  "Wilbur Ross",
  "Andrew Puzder",
  "Tom Price",
  "Sonny Perdue",
  "Ben Carson",
  "Elaine Chao",
  "Rick Perry",
  "Betsy DeVos",
  "David Shulkin",
  "John F Kelly",
  "Reince Priebus",
  "Nikki Haley",
  "Scott Pruitt",
  "Robert Lighthizer",
  "Mick Mulvaney",
  "Linda McMahon"
]

############################################################

# Twitter API
my_consumer_key = Secrets::CABINETS_CONSUMER_KEY
my_consumer_secret = Secrets::CABINETS_CONSUMER_SECRET
my_access_token = Secrets::CABINETS_ACCESS_TOKEN
my_access_token_secret = Secrets::CABINETS_ACCESS_TOKEN_SECRET

# Configure Twitter API connection
$client = Twitter::REST::Client.new do |config|
  config.consumer_key        = my_consumer_key
  config.consumer_secret     = my_consumer_secret
  config.access_token        = my_access_token
  config.access_token_secret = my_access_token_secret
end

############################################################

# Firebase Setup
base_uri = 'https://cabinets-68f28.firebaseio.com'
database_secret = 'YKFxblgf4nCGU4OetM7RXzUG2UMJbIcJOZ5lz40n'
$firebase = Firebase::Client.new(base_uri, database_secret)

############################################################

def update_database
  $firebase.set('last_updated', Firebase::ServerValue::TIMESTAMP)

  CABINET_MEMBERS.each do |member|
    tweets = $client.search(member, {count: 100}).to_h
    statuses = tweets[:statuses]

    reviews = []
    statuses.each do |status|
      # don't include retweets
      if !(/^RT/ =~ status[:text])
        review = {
          text: status[:text],
          author: status[:user][:screen_name],
          timestamp: status[:created_at],
        }
        reviews.push(review)
      end
    end
    $firebase.set(member.tr(' ', '_'), reviews)
  end
end

############################################################
def get_reviews
  # don't update the firebase more than once every 10 minutes, to avoid Twitter API rate limiting (180 per 15 minutes) and 
  # Firebase transfer monthly/daily limits
  last_timestamp = $firebase.get('last_updated').body
  current_timestamp = $firebase.set('current_time', Firebase::ServerValue::TIMESTAMP).body

  if current_timestamp - last_timestamp > TEN_MINUTES
    update_database
  end

  data = $firebase.get('')
  return data.body.to_json
end
