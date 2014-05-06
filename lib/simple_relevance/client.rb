require 'rubygems'
require 'httparty'
require 'json'

require_relative 'action_type'

# A Ruby API wrapper for SimpleRelevance
# free to use and unlicensed
# requires httparty

module SimpleRelevance
  class Client
    include HTTParty

    def initialize(username=ENV["SIMPLE_RELEVANCE_USERNAME"] , api_key=ENV["SIMPLE_RELEVANCE_API_KEY"] , async=1)
      @async = async
      @basic_auth = {password: api_key, username: username}
    end

    # Generic entry method to call any of the api methods
    # Useful for use with e.g. sidekiq delayed extensions
    #
    # e.g. SimpleRelevance.delay.call_api(username: "foo", api_key: "bar", method: :get_user, opts: { email: "foo@bar.com" }
    def self.call_api(username: ENV["SIMPLE_RELEVANCE_USERNAME"], api_key: ENV["SIMPLE_RELEVANCE_API_KEY"], method:, opts:{})
      new(username, api_key).send(method, opts)
    end

    # Reserved keys:
    # -first_name (users only)
    # -last_name (users only)
    # -twitter_handle (users only)
    # -image_url (users and items)
    def add_user(opts={})
      payload = {
        email:     opts.delete(:email)   || raise("email is required"),
        user_id:   opts.delete(:user_id) || raise("user_id is required"),
        data_dict: opts
      }

      self._post('users/', payload)
    end

    def get_user(opts={})
      self._get('users', opts)
    end

    # Reserved Key List:
    # -latitude
    # -longitude
    # -business_name (business items only) - this attribute is very important! If you have a business as an item, upload a clear and well-chosen business_name.
    # -market (items only)
    # -neighborhood (items only)
    # -zipcode
    # -sku (product items and variants only)
    # -image_url (users and items)
    # -image_url_small (items only)
    # -item_url (items only)
    # -price (items and variants only)
    # -starts (items and variants only)
    # -expires (items and variants only)
    # -description (items only)
    # -in_stock (items only)
    # -name (variants only)
    # -external_id (variants only)
    # -discount (items and variants only) - this can be in a variety of formats. "2%",20,.2,".2" - any string or number larger than 1 will be treated as "$$ off" and used along with price info to calculate percent discount.
    def add_item(opts={})
      payload = {
        item_id:    opts.delete(:item_id)   || raise("item_id is required"),
        item_name:  opts.delete(:item_name) || raise("item_name is required"),
        item_type:  opts.delete(:item_type) || 'product',
        variants:   opts.delete(:variants),
        data_dict:  opts
      }
      self._post('items/', payload)
    end

    def add_click(opts={})
      add_action(opts.merge(action_type: ActionType::CLICK))
    end

    def add_purchase(opts={})
      add_action(opts.merge(action_type: ActionType::PURCHASE))
    end

    def add_email_open(opts={})
      add_action(opts.merge(action_type: ActionType::EMAIL_OPEN))
    end

    def get_predictions(opts={})
      opts[:email] || raise("email is required")
      self._get('items/', opts)
    end

    def _post(endpoint, post_data)
      data = post_data.merge(async: @async)
      self.class.post("https://www.simplerelevance.com/api/v3/#{endpoint}", basic_auth: @basic_auth, body: JSON.dump(data), options: {headers: {'Content-Type'=>'application/json', accept:'application/json'}})
    end

    def _get(endpoint, params)
      params = params.merge(async: @async)
      self.class.get("https://www.simplerelevance.com/api/v3/#{endpoint}", basic_auth: @basic_auth, query: params)
    end

    private

    # action_type: purchases (action type 1), clicks (action type 0), and email opens (action type 5)
    # required: item_id or item_name, user_id or email, action_type
    # Highly suggested parameters include timestamp (in UTC), price, zipcode, and,
    # if you are matching a preexisting item by name and not by item_id, item_type.
    def add_action(opts={})
      opts[:item_id] || raise("item_id is required")
      opts[:user_id] || raise("user_id is required")
      opts[:action_type] || raise("action_type is required")

      self._post("actions/", opts)
    end
  end
end
