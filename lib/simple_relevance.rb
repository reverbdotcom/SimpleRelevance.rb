require 'rubygems'
require 'httparty'

# A Ruby API wrapper for SimpleRelevance
# free to use and unlicensed
# requires httparty

# you can get an API key by signing up for SimpleRelevance on the site. Signup is free.
# async: when you are done testing, set async=1. This will speed up API response times by a factor of 2 or 3.
# predictions: this is the part of SimpleRelevance that eventually costs money to use. They will not be available right away, as our automated model builds happen nightly. Please get in touch during business hours (inquiries@simplerelevance.com) if you want us to build a model sooner.

# documentation: note that documentation is available at simplerelevance.com/docs/api2

# also, I have not used ruby in more than a year, so I apologize for creaky/ugly code. Anyway, all functionality has been tested.

# BATCH MODE: note that converting to use batch mode is easy - all POST requests accept a list, as you can see, so simply modify the requests to take a list of hashes as input.

class SimpleRelevance
  include HTTParty

  def initialize(key,async=0)
    @api_key=key
    @async=async
  end

  def _post(endpoint,post_data)
    data = {:api_key=>@api_key,:async=>@async,:data=>post_data}
    self.class.post("https://www.simplerelevance.com/api/v3/#{endpoint}",:body => JSON.dump(data), :options => {:headers => {'Content-Type'=>'application/json', :accept =>'application/json'}})
  end

  def _get(endpoint,get_data)
    data = {:api_key=>@api_key,:async=>@async}
    data.merge!(get_data)
    puts data
    self.class.get("https://www.simplerelevance.com/api/v3/#{endpoint}",:query => data)
  end

  def add_user(email,opts={})
    zipcode = opts[:zipcode] || nil
    user_id = opts[:user_id] || nil
    data_dict = opts[:data_dict] || {}

    payload = [{:email=>email,:zipcode=>zipcode,:user_id=>user_id,:data_dict=>data_dict}]
    self._post('users/',payload)
  end

  def add_item(item_name,item_id,opts={})
    item_type = opts[:item_type] || 'product'
    data_dict = opts[:data_dict] || {}
    variants = opts[:variants] || {}

    payload = [{:item_name=>item_name,:item_id=>item_id,:item_type=>item_type,:data_dict=>data_dict,:variants=>variants}]
    self._post('items/',payload)
  end

  # action_hook should be "clicks/" or "purchases/"
  # takes: action_hook="purchases/",user_id=nil,item_id=nil,email=nil,item_name=nil,timestamp=nil,price=nil,zipcode=nil

  def add_action(opts={})
    action_hook = opts[:action_hook] || "purchases/"
    opts.delete(:action_hook)
    payload = [opts]
    self._post(action_hook,payload)
  end


  def get_predictions(email,opts={})
    opts[:email]=email
    self._get('items/',opts)
  end

end

