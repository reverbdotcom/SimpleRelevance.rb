#!/usr/bin/env ruby

# Use this to test your connection to simple relevance
# set ENV variables for SIMPLE_RELEVANCE_USERNAME and SIMPLE_RELEVANCE_API_KEY
#
# Example:
# (in ~/.profile)
#
#   export SIMPLE_RELEVANCE_USERNAME=reverb0
#   export SIMPLE_RELEVANCE_API_KEY=bff9ba28c7cf4d645503
#
$LOAD_PATH << "."
require 'lib/simple_relevance'

sr = SimpleRelevance.new(ENV['SIMPLE_RELEVANCE_USERNAME'], ENV['SIMPLE_RELEVANCE_API_KEY'], async=0)
puts sr.add_user("user1@foo.com", 1, data_dict: {testingagain: "2"})
puts sr.add_user("user2@foo.com", 1, data_dict: {testingagain: "2"})
puts sr.add_item("someitem", 1, data_dict: {testattr: "wahoo"})
puts sr.add_click(user_id: 1, item_id: 1)
puts sr.add_email_open(user_id: 1, item_id: 1)
#FIXME: purchase call is not working
# puts sr.add_purchase(user_id: 2, item_id: 1)
puts sr.get_predictions('user1@foo.com')
