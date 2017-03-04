require 'base64'

module Wdmc
  class User < Thor
    include Enumerable

    def initialize(*args)
      @wdmc = Wdmc::Client.new
      super
    end

    desc 'list', 'List all users'
    def list
      users = @wdmc.all_users
      puts "Users".upcase.color(:magenta)
      users.each do |user|
        puts "\s- #{user[:username]}"
      end
    end

    desc 'show [USERNAME]', 'Show user information'
    def show( name )
      users = @wdmc.find_user( name )
      user_exists = @wdmc.user_exists?( name )
      abort "\nUser does not exist: ".color(:yellow) + "#{name}".color(:cyan) unless user_exists.include?( name )
      users.each do |user|
        puts "Username:\s".upcase.color(:magenta) + user[:username]
        puts "\sUser ID\t\t: ".color(:whitesmoke) + "#{user[:user_id]}"
        puts "\sFullname\t\t: ".color(:whitesmoke) + "#{user[:fullname]}" unless user[:fullname].empty?
        puts "\sAdmin\t\t\t: ".color(:whitesmoke) + "#{user[:is_admin]}"
        puts "\sPassword set\t\t: ".color(:whitesmoke) + "#{user[:is_password]}".color(:green) if user[:is_password] == 'true'
        puts "\sPassword set\t\t: ".color(:whitesmoke) + "#{user[:is_password]}".color(:orange) if user[:is_password] == 'false'
      end
    end

    desc 'create [USERNAME] [OPTIONS]', 'Create an new user'
    method_option :password, :aliases => '-p', :desc => 'Password', :type => :string
    method_option :fullname, :desc => 'Fullname of the user to be created', :type => :string
    method_option :first_name, :aliases => '-f', :desc => 'First name of the user to be created', :type => :string
    method_option :last_name, :aliases => '-l', :desc => 'Last name of the user to be created', :type => :string
    method_option :group_names, :aliases => '-g', :desc => 'Accepts a comma separated list of group names', :type => :string
    method_option :email, :aliases => '-m', :desc => 'If provided, a device user will be created as well as a local (Linux) user.', :type => :string
    method_option :admin, :aliases => '-a', :desc => 'Give user admin rights', :type => :boolean
    def create( name )
      password = Base64.strict_encode64(options[:password]) if options[:password]
      user_exists = @wdmc.user_exists?( name )
      abort "\nUser does not exist: ".color(:yellow) + "#{name}".color(:cyan) if user_exists.include?( name )
      begin
        groups = ['cloudholders']
        groups.push options[:group_names] if options[:group_names]
        data = {
          :email => options[:email],
          :username => name,
          :password => password,
          :fullname => options[:fullname],
          :is_admin => options[:admin],
          :group_names => groups.join(','),
          :first_name => options[:first_name],
          :last_name => options[:last_name]
        }
        puts "Create user:\s".color(:whitesmoke) + "OK".color(:green) if @wdmc.add_user( data )
      rescue RestClient::ExceptionWithResponse => e
        puts eval(e.response)[:users][:error_message].color(:orange)
      end
    end

    desc 'update [USERNAME] [OPTIONS]', 'Updates an existing user'
    method_option :new_username, :aliases => '-r', :desc => 'New username', :type => :string
    method_option :password, :aliases => '-p', :desc => 'New password', :type => :string
    method_option :fullname, :desc => 'Update Fullname of the user', :type => :string
    method_option :first_name, :aliases => '-f', :desc => 'Update first name of the user', :type => :string
    method_option :last_name, :aliases => '-l', :desc => 'Update last name of the user', :type => :string
    method_option :admin, :aliases => '-a', :desc => '[true/false] default = false, Give user admin rights ', :type => :boolean, :default => false
    def update( name )
      password = Base64.strict_encode64(options[:password]) if options[:password]
      user_exists = @wdmc.user_exists?( name )
      abort "\nUser does not exist: ".color(:yellow) + "#{name}".color(:cyan) unless user_exists.include?( name )
      begin
        data = {
          :username => options[:new_username] || name,
          :password =>  password,
          :fullname => options[:fullname],
          :is_admin => options[:admin],
          :first_name => options[:first_name],
          :last_name => options[:last_name]
        }
        puts "Update user:\s".color(:whitesmoke) + "OK".color(:green) if @wdmc.update_user( name, data )
      rescue RestClient::ExceptionWithResponse => e
        puts eval(e.response)[:users] #[:error_message].color(:orange)
      end
    end

    desc 'delete [USERNAME]', 'Delete a user'
    method_option :force, :aliases => '-f', :desc => 'force', :type => :boolean
    def delete( name )
      user_exists = @wdmc.user_exists?( name )
      abort "\nUser does not exist: ".color(:yellow) + "#{name}".color(:cyan) unless user_exists.include?( name )
      unless options['force']
        puts "\nAre you sure you want to delete this user?\s".color(:orange) + "#{name}".color(:whitesmoke)
        return unless yes?("DELETE? (yes/no):")
      end
      puts "Delete user:\s".color(:whitesmoke) + "OK".color(:green) if @wdmc.delete_user( name )
    end

  end
end
