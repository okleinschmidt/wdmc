require 'rest-client'
require 'json'

module Wdmc
  class Client

    include Enumerable

    def initialize(*args)
      @config = Wdmc::Config.load
      @cookiefile = File.join(ENV['HOME'], '.wdmc_cookie')
      login
    end

    def login
      @url = @config['url']
      @username = @config['username']
      @password = @config['password']
      api = RestClient.get("#{@url}/api/2.1/rest/local_login?username=#{@username}&password=#{@password}")
      cookie = api.cookies
      File.write(@cookiefile, api.cookies)
    end

    def cookies
      file = File.read(@cookiefile)
      eval(file)
      #file = YAML.load_file(@cookiefile)
    end

    # device
    def system_information
      response = RestClient.get("#{@config['url']}/api/2.1/rest/system_information", {accept: :json, :cookies => cookies})
      eval(response)[:system_information]
    end

    def system_state
      response = RestClient.get("#{@config['url']}/api/2.1/rest/system_state", {accept: :json, :cookies => cookies})
      eval(response)[:system_state]
    end

    def firmware
      response = RestClient.get("#{@config['url']}/api/2.1/rest/firmware_info", {accept: :json, :cookies => cookies})
      eval(response)[:firmware_info]
    end

    def device_description
      response = RestClient.get("#{@config['url']}/api/2.1/rest/device_description", {accept: :json, :cookies => cookies})
      JSON.parse(response)['device_description']
    end

    def network
      response = RestClient.get("#{@config['url']}/api/2.1/rest/network_configuration", {accept: :json, :cookies => cookies})
      eval(response)[:network_configuration]
      #JSON.parse(response)['network_configuration']
    end

    # storage
    def storage_usage
      response = RestClient.get("#{@config['url']}/api/2.1/rest/storage_usage", {accept: :json, :cookies => cookies})
      eval(response)[:storage_usage]
    end

    ## working with shares
    # get all shares
    def all_shares
      response = RestClient.get("#{@config['url']}/api/2.1/rest/shares", {accept: :json, :cookies => cookies})
      JSON.parse(response)['shares']['share']
    end

    # find a share by name
    def find_share( name )
      result = []
      all_shares.each do |share|
        result.push share if share['share_name'] == name
      end
      return result
    end

    # check if share with exists
    def share_exists?( name )
      result = []
      all_shares.each do |share|
        result.push share['share_name'] if share['share_name'].include?(name)
      end
      return result
    end

    # add new share
    def add_share( data )
      response = RestClient.post("#{@config['url']}/api/2.1/rest/shares", data, {accept: :json, :cookies => cookies})
      return response.code
    end

    # modifies a share
    def modify_share( data )
      response = RestClient.put("#{@config['url']}/api/2.1/rest/shares", data, {accept: :json, :cookies => cookies})
      return response.code
    end

    # delete a share
    def delete_share( name )
      response = RestClient.delete("#{@config['url']}/api/2.1/rest/shares/#{name}", {accept: :json, :cookies => cookies})
      return response.code
    end

    ## working with ACL of a share
    # get the specified share access
    def get_acl( name )
      response = RestClient.get("#{@config['url']}/api/2.1/rest/share_access/#{name}", {accept: :json, :cookies => cookies})
      JSON.parse(response)['share_access_list']
    end

    def set_acl( data )
      response = RestClient.post("#{@config['url']}/api/2.1/rest/share_access", data, {accept: :json, :cookies => cookies})
      return response.code
    end

    def modify_acl( data )
      response = RestClient.put("#{@config['url']}/api/2.1/rest/share_access", data, {accept: :json, :cookies => cookies})
      return response.code
    end

    def delete_acl( data )
      # well, I know the code below is not very pretty...
      # if someone knows how this shitty delete with rest-client will work
      response = RestClient.delete("#{@config['url']}/api/2.1/rest/share_access?share_name=#{data['share_name']}&username=#{data['username']}", {accept: :json, :cookies => cookies})
      return response
    end
    ## ACL end

    ## TimeMachine
    # Get TimeMachine Configuration
    def get_tm
      response = RestClient.get("#{@config['url']}/api/2.1/rest/time_machine", {accept: :json, :cookies => cookies})
      eval(response)[:time_machine]
    end

    # Set TimeMachine Configuration
    def set_tm( data )
      response = RestClient.put("#{@config['url']}/api/2.1/rest/time_machine", data, {accept: :json, :cookies => cookies})
      return response
    end

    ## Users
    # Get all users
    def all_users
      response = RestClient.get("#{@config['url']}/api/2.1/rest/users", {accept: :json, :cookies => cookies})
      eval(response)[:users][:user]
    end

    # find a user by name
    def find_user( name )
      result = []
      all_users.each do |user|
        result.push user if user[:username] == name
      end
      return result
    end

    # check if user with name exists
    def user_exists?( name )
      result = []
      all_users.each do |user|
        result.push user[:username] if user[:username].include?(name)
      end
      return result
    end

    # add new user
    def add_user( data )
      response = RestClient.post("#{@config['url']}/api/2.1/rest/users", data, {accept: :json, :cookies => cookies})
      return response.code
    end

    # update an existing user
    def update_user( name, data )
      response = RestClient.put("#{@config['url']}/api/2.1/rest/users/#{name}", data, {accept: :json, :cookies => cookies})
      return response.code
    end

    # delete user
    def delete_user( name )
      response = RestClient.delete("#{@config['url']}/api/2.1/rest/users/#{name}", {accept: :json, :cookies => cookies})
      return response.code
    end

    ## Users

    def volumes
      login
      response = RestClient.get("#{@config['url']}/api/2.1/rest/volumes", {accept: :json, :cookies => cookies})
      volumes = JSON.parse(response)['volumes']['volume']
    end

  end
end
