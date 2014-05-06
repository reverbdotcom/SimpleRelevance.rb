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
require 'spec_helper'
require 'rspec/expectations'

RSpec::Matchers.define :be_successful do |expected|
  match do |actual|
    actual["message"] == "success"
  end
end

describe SimpleRelevance::Client do
  use_vcr_cassette

  let(:email) { "user1@foo.com" }
  let(:username) { ENV["SIMPLE_RELEVANCE_USERNAME"] }
  let(:api_key) { ENV["SIMPLE_RELEVANCE_API_KEY"] }

  let(:sr) do
    if !username || !api_key
      raise "Please specify SIMPLE_RELEVANCE_API_KEY and SIMPLE_RELEVANCE_USERNAME in your environment to run tests."
    end

    described_class.new(username, api_key, async=1)
  end

  it "adds users" do
    sr.add_user(email: email, user_id: 1, some_property: "my value").should be_successful
  end

  it "retreives users" do
    sr.get_user(user_email: email)["total"].should == 1
  end

  it "adds and retrieves items" do
    sr.add_item(item_name: "someitem", item_id: 1, data_dict: {testattr: "wahoo"}).should be_successful
  end

  it "tracks clicks" do
    sr.add_click(user_id: 1, item_id: 1).should be_successful
  end

  it "tracks email opens" do
    sr.add_email_open(user_id: 1, item_id: 1).should be_successful
  end

  it "tracks purchases" do
    sr.add_purchase(user_id: 1, item_id: 1).should be_successful
  end

  describe "class level api call" do
    it "adds users" do
      described_class.call_api(username: username, api_key: api_key, method: :add_user, opts: {
        user_id: 1,
        email: "foo@bar.com"
      }).should be_successful
    end

  end
end
