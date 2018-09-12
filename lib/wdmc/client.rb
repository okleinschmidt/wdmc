require 'rest-client'
require 'json'

module Wdmc
  class Client

    include Enumerable

    def initialize(*args)
      @config = Wdmc::Config.load
      @config[:verify_ssl] = (@config['validate_cert'].nil? or @config['validate_cert'] != false) ? true : false
      @config['api_net_nl_bug'] = @config['api_net_nl_bug'].nil? ? false : @config['api_net_nl_bug']
      @cookiefile = File.join(ENV['HOME'], '.wdmc_cookie')
      login
    end

    def login
      @url = @config['url']
      @username = @config['username']
      @password = @config['password']

      begin
        api = get("#{@url}/api/2.1/rest/local_login?username=#{@username}&password=#{@password}")
      rescue RestClient::SSLCertificateNotVerified => e
        if @config['validate_cert'] == 'warn'
          $stderr.puts("Warning: #{ e.class.name}: #{ e.message } for host URL: '#{ @url }'")
          @config[:verify_ssl] = false
          api = get("#{@url}/api/2.1/rest/local_login?username=#{@username}&password=#{@password}")
        else
          raise(e)
        end
      end

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
      response = get("#{@config['url']}/api/2.1/rest/system_information", {accept: :json, :cookies => cookies})
      JSON.parse(response, :symbolize_names => true)[:system_information]
    end

    def system_state
      response = get("#{@config['url']}/api/2.1/rest/system_state", {accept: :json, :cookies => cookies})
      JSON.parse(response, :symbolize_names => true)[:system_state]
    end

    def firmware
      response = get("#{@config['url']}/api/2.1/rest/firmware_info", {accept: :json, :cookies => cookies})
      JSON.parse(response, :symbolize_names => true)[:firmware_info]
    end

    def device_description
      response = get("#{@config['url']}/api/2.1/rest/device_description", {accept: :json, :cookies => cookies})
      JSON.parse(response, :symbolize_names => true)[:device_description]
    end

    def network
      response = get("#{@config['url']}/api/2.1/rest/network_configuration", {accept: :json, :cookies => cookies})
      if @config['api_net_nl_bug']
        response = response.delete("\n")
      end
      begin
        JSON.parse(response, :symbolize_names => true)[:network_configuration]
      rescue JSON::ParserError => e
        unless @config['api_net_nl_bug']
          $stderr.puts(<<~EOL.tr("\n", " ")
             Warning: Consider adding 'api_net_nl_bug: true' to your configuration file
             to mitigate a known bug retrieving network configuration data.
             EOL
          )
        end
        raise e
      end
    end

    # storage
    def storage_usage
      response = get("#{@config['url']}/api/2.1/rest/storage_usage", {accept: :json, :cookies => cookies})
      JSON.parse(response, :symbolize_names => true)[:storage_usage]
    end

    ## working with shares
    # get all shares
    def all_shares
      response = get("#{@config['url']}/api/2.1/rest/shares", {accept: :json, :cookies => cookies})
      JSON.parse(response, :symbolize_names => true)[:shares][:share]
    end

    # find a share by name
    def find_share( name )
      result = []
      all_shares.each do |share|
        result.push share if share[:share_name] == name
      end
      return result
    end

    # check if share with exists
    def share_exists?( name )
      result = []
      all_shares.each do |share|
        result.push share[:share_name] if share[:share_name].include?(name)
      end
      return result
    end

    # add new share
    def add_share( data )
      response = post("#{@config['url']}/api/2.1/rest/shares", data, {accept: :json, :cookies => cookies})
      return response.code
    end

    # modifies a share
    def modify_share( data )
      response = put("#{@config['url']}/api/2.1/rest/shares", data, {accept: :json, :cookies => cookies})
      return response.code
    end

    # delete a share
    def delete_share( name )
      response = delete("#{@config['url']}/api/2.1/rest/shares/#{name}", {accept: :json, :cookies => cookies})
      return response.code
    end

    ## working with ACL of a share
    # get the specified share access
    def get_acl( name )
      response = get("#{@config['url']}/api/2.1/rest/share_access/#{name}", {accept: :json, :cookies => cookies})
      JSON.parse(response, :symbolize_names => true)[:share_access_list]
    end

    def set_acl( data )
      response = post("#{@config['url']}/api/2.1/rest/share_access", data, {accept: :json, :cookies => cookies})
      return response.code
    end

    def modify_acl( data )
      response = put("#{@config['url']}/api/2.1/rest/share_access", data, {accept: :json, :cookies => cookies})
      return response.code
    end

    def delete_acl( data )
      # well, I know the code below is not very pretty...
      # if someone knows how this shitty delete with rest-client will work
      response = delete("#{@config['url']}/api/2.1/rest/share_access?share_name=#{data[:share_name]}&username=#{data[:username]}", {accept: :json, :cookies => cookies})
      return response
    end
    ## ACL end

    ## TimeMachine
    # Get TimeMachine Configuration
    def get_tm
      response = get("#{@config['url']}/api/2.1/rest/time_machine", {accept: :json, :cookies => cookies})
      JSON.parse(response, :symbolize_names => true)[:time_machine]
    end

    # Set TimeMachine Configuration
    def set_tm( data )
      response = put("#{@config['url']}/api/2.1/rest/time_machine", data, {accept: :json, :cookies => cookies})
      return response
    end

    ## Users
    # Get all users
    def all_users
      response = get("#{@config['url']}/api/2.1/rest/users", {accept: :json, :cookies => cookies})
      JSON.parse(response, :symbolize_names => true)[:users][:user]
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
      response = post("#{@config['url']}/api/2.1/rest/users", data, {accept: :json, :cookies => cookies})
      return response.code
    end

    # update an existing user
    def update_user( name, data )
      response = put("#{@config['url']}/api/2.1/rest/users/#{name}", data, {accept: :json, :cookies => cookies})
      return response.code
    end

    # delete user
    def delete_user( name )
      response = delete("#{@config['url']}/api/2.1/rest/users/#{name}", {accept: :json, :cookies => cookies})
      return response.code
    end

    ## Users

    def volumes
      login
      response = get("#{@config['url']}/api/2.1/rest/volumes", {accept: :json, :cookies => cookies})
      volumes = JSON.parse(response)['volumes']['volume']
    end

    private

    def get(url, headers={}, &block)
      execute_request(:method => :get, :url => url, :headers => headers, &block)
    end

    def post(url, payload, headers={}, &block)
      execute_request(:method => :post, :url => url, :payload => payload, :headers => headers, &block)
    end

    def put(url, payload, headers={}, &block)
      execute_request(:method => :put, :url => url, :payload => payload, :headers => headers, &block)
    end

    def delete(url, headers={}, &block)
      execute_request(:method => :delete, :url => url, :headers => headers, &block)
    end

    def execute_request(args, &block)
      args[:verify_ssl] = @config[:verify_ssl]
      RestClient::Request.execute(args, &block)
    end

  end
end
