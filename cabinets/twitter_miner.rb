require 'twitter'
require 'pp'


# Twitter API
my_consumer_key = "IfApuE1yNWV5CiabxNTSSRRZY"
my_consumer_secret = "1Q1R2kZ982RaydelHVCys8yNgdEDsxUPQoRyYv0yuE6RB8ipGb"
my_access_token = "3976727145-igFDlwrfpMHwNRtoLfVzBvD6k8oTGOFkUdnXR8h"
my_access_token_secret = "5WNj24nUDuJYdhd3EFdI39S5OKPCxfVRkezUkq1tf9Hpa"

# Configure Twitter API connection
$client = Twitter::REST::Client.new do |config|
  config.consumer_key        = my_consumer_key
  config.consumer_secret     = my_consumer_secret
  config.access_token        = my_access_token
  config.access_token_secret = my_access_token_secret
end


tweets = $client.search('How big can you dream', {count: 100}).to_h
statuses = tweets[:statuses]
statuses.each do |status|
  pp status[:text]
  puts
end
