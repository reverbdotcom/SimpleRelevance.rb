require 'rubygems'
require 'httparty'
require 'json'

require_relative 'simple_relevance/action_type'

# A Ruby API wrapper for SimpleRelevance
# free to use and unlicensed
# requires httparty

class SimpleRelevance
  include HTTParty

  def initialize(username, api_key, async=0)
    @async=async
    @basic_auth = {password: api_key, username: username}
  end

  def _post(endpoint,post_data)
    data = post_data.merge(async: @async)
    self.class.post("https://www.simplerelevance.com/api/v3/#{endpoint}", basic_auth: @basic_auth, body: JSON.dump(data), options: {headers: {'Content-Type'=>'application/json', accept:'application/json'}})
  end

  def _get(endpoint, params)
    params = params.merge(async: @async)
    self.class.get("https://www.simplerelevance.com/api/v3/#{endpoint}", basic_auth: @basic_auth, query: params)
  end

  # Reserved keys:
  # -first_name (users only)
  # -last_name (users only)
  # -twitter_handle (users only)
  # -image_url (users and items)
  def add_user(email, user_id, opts={})
    self._post('users/', opts.merge(email: email, user_id: user_id))
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
  def add_item(item_name, item_id, opts={})
    item_type = opts[:item_type] || 'product'
    data_dict = opts[:data_dict]
    variants = opts[:variants]

    payload = {item_name: item_name, item_id: item_id, item_type: item_type, data_dict:data_dict, variants:variants}
    self._post('items/',payload)
  end

  def add_click(opts={})
    add_action(opts.merge(action_type: ActionType::CLICK))
  end

  # NOTE: appears to require email, even though simplerelevance docs do not state this
  def add_purchase(opts={})
    add_action(opts.merge(action_type: ActionType::PURCHASE))
  end

  def add_email_open(opts={})
    add_action(opts.merge(action_type: ActionType::EMAIL_OPEN))
  end

  # FIXME: I don't think this is the right API
  def get_predictions(email,opts={})
    opts[:email] = email
    self._get('items/', opts)
  end

  private

  # action_type: purchases (action type 1), clicks (action type 0), and email opens (action type 5)
  # required: item_id or item_name, user_id or email, action_type
  # Highly suggested parameters include timestamp (in UTC), price, zipcode, and,
  # if you are matching a preexisting item by name and not by item_id, item_type.
  def add_action(opts={})
    self._post("actions/", opts)
  end


end

