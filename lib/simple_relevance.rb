require 'rubygems'
require 'httparty'
require 'json'

# A Ruby API wrapper for SimpleRelevance
# free to use and unlicensed
# requires httparty

class SimpleRelevance
  include HTTParty

  def initialize(username, api_key, async=0)
    @async=async
    @basic_auth = {:password => api_key, :username => username}
  end

  def _post(endpoint,post_data)
    data = {:async=>@async,:data=>post_data}
    self.class.post("https://www.simplerelevance.com/api/v3/#{endpoint}", :basic_auth => @basic_auth, :body => JSON.dump(data), :options => {:headers => {'Content-Type'=>'application/json', :accept =>'application/json'}})
  end

  def _get(endpoint,get_data)
    data = {:async=>@async}
    data.merge!(get_data)
    puts data
    self.class.get("https://www.simplerelevance.com/api/v3/#{endpoint}", :basic_auth => @basic_auth, :query => data)
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

