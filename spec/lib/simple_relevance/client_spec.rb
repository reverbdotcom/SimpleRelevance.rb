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
    [200, 201].include?(actual.code)
  end
end

describe SimpleRelevance::Client do
  use_vcr_cassette

  let(:email) { "user1@foo.com" }
  let(:email2) { "user2@foo.com" }
  let(:username) { ENV["SIMPLE_RELEVANCE_USERNAME"] }
  let(:api_key) { ENV["SIMPLE_RELEVANCE_API_KEY"] }

  let(:sr) do
    if !username || !api_key
      raise "Please specify SIMPLE_RELEVANCE_API_KEY and SIMPLE_RELEVANCE_USERNAME in your environment to run tests."
    end

    described_class.new(username, api_key, async=0)
  end

  it "adds users" do
    sr.add_user(email: email, user_id: 1, some_property: "my value").should be_successful
  end

  it "batch adds users" do
    sr.batch_add_users(
      users: [
        { email: email, user_id: 1, some_property: "my value" },
        { email: email2, user_id: 2, some_property: "some prop" }
      ]
    ).should be_successful
  end

  it "retreives users" do
    sr.get_user(user_email: email)["total"].should == 1
  end

  it "adds items" do
    sr.add_item(
      item_name: "some & item with ampersand and \t character w/ a slash and \"quotes\"",
      item_id: "100-foo",
      testattr: "wahoo",
      item_url: "http://foo.com/bar",
      image_url: "http://google.com/some.png"
    ).should be_successful
  end

  it "batch adds items" do
    sr.batch_add_items(items:[
      {
        item_name: "foo-item1 & ampersand test",
        item_id: "101-foo",
        testattr: "wahoo",
        item_url: "http://foo.com/bar1",
        image_url: "http://google.com/some.png"
      },

      # Testing string keys below
      {
        item_name: "foo-item2",
        item_id: "102-foo",
        testattr: "wahoo",
        "item_url" => "http://foo.com/bar2",
        "image_url" => "http://google.com/some.png"
      }
    ]).should be_successful
  end

  it "tracks email clicks" do
    # sr.add_email_click(user_id: 1, item_id: 1).should be_successful
    sr.add_email_click(user_id: 1, item_id: "101-foo").should be_successful
    sr.add_email_click(user_id: 1, item_id: "102-foo").should be_successful
  end

  it "tracks item views" do
    # sr.add_email_click(user_id: 1, item_id: 1).should be_successful
    sr.add_item_view(user_id: 1, item_id: "101-foo").should be_successful
    sr.add_item_view(user_id: 1, item_id: "102-foo").should be_successful
  end

  it "batch tracks clicks" do
    sr.batch_add_email_clicks(clicks: [
      { user_id: 100, item_id: "101-foo"},
      { user_id: 101, item_id: "102-foo"}
    ]).should be_successful
  end

  it "tracks email opens" do
    sr.add_email_open(user_id: 1, item_id: 1).should be_successful
  end

  it "batch tracks email opens" do
    sr.batch_add_email_opens(email_opens: [
      { user_id: 100, item_id: "101-foo"},
      { user_id: 101, item_id: "102-foo"}
    ]).should be_successful
  end

  it "tracks purchases" do
    sr.add_purchase(user_id: 1, item_id: 1).should be_successful
  end

  it "batch tracks purchases" do
    sr.batch_add_purchases(purchases: [
      { user_id: 100, item_id: "101-foo"},
      { user_id: 101, item_id: "102-foo"}
    ]).should be_successful
  end


  describe "class level api call" do
    it "adds users" do
      described_class.call_api(username: username, api_key: api_key, method: :add_user, opts: {
        user_id: 1,
        email: "foo@bar.com"
      }).should be_successful
    end

    it "adds users in bulk" do
      described_class.call_api(username: username, api_key: api_key, 
        method: :batch_add_users, opts: {
        users: [
          {
            user_id: 1,
            email: "foo@bar.com"
          }
        ]
      }).should be_successful
    end
  end
end
