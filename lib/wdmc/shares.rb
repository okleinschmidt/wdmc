require "wdmc/acl"

module Wdmc
  class Share < Thor
    include Enumerable

    def initialize(*args)
      @wdmc = Wdmc::Client.new
      @device_description = @wdmc.device_description
      super
    end

    desc 'list', 'List all shares'
    def list
      shares = @wdmc.all_shares
      puts "Available Shares".upcase.color(:magenta)
      shares.each do |share|
        puts "\s- #{share['share_name']}"
      end
    end

    desc 'show [NAME]', 'Show share'
    def show( name )
      shares = @wdmc.find_share( name )
      share_exists = @wdmc.share_exists?( name )
      abort "\nShare does not exist: ".color(:yellow) + "#{name}".color(:cyan) unless share_exists.include?( name )
      shares.each do |share|
        puts "Name:\s".upcase.color(:magenta) + share['share_name']
        puts "\sRemote Access\t\t: ".color(:whitesmoke) + "#{share['remote_access']}"
        puts "\sPublic Access\t\t: ".color(:whitesmoke) + "#{share['public_access']}"
        puts "\sMedia Serving\t\t: ".color(:whitesmoke) + "#{share['media_serving']}"
        if share['share_access']
          puts "Permissions\t\t ".upcase.color(:magenta)
          share['share_access'].map do |access|
            puts "\s#{access['username']}\t\t\t:\s" + access['access'].color(:green) if access['access'] == 'RW'
            puts "\s#{access['username']}\t\t\t:\s" + access['access'].color(:cyan) if access['access'] == 'RO'
          end
        end
      end
    end

    desc 'create [NAME]', 'Create a new share'
    method_option :description, :aliases => '-d', :desc => 'Volume description', :required => false
    method_option :media_serving, :aliases => '-m', :desc => 'Enable media serving', :type => :boolean, :default => true
    method_option :public_access, :aliases => '-p', :desc => 'Enable public access', :type => :boolean, :default => false
    method_option :samba_available, :aliases => '-s', :desc => 'Enable samba access', :type => :boolean, :default => true
    method_option :share_access_locked, :aliases => '-l', :desc => 'When set to true, share access cannot be set or modified on this Share once created.', :type => :boolean, :default => false
    method_option :grant_share_access, :aliases => '-g', :desc => 'When set to true, automatically grants RW share access to the new Share for the User who is creating the new Share.', :type => :boolean, :default => false
    def create( name )
      share_exists = @wdmc.share_exists?( name )
      abort "Share already exists!".color(:yellow) if share_exists.include?( name )
      begin
        data = {
          :share_name => name,
          :description => options['description'],
          :media_serving => options['media_serving'],
          :public_access => options['public_access'],
          :samba_available => options['samba_available'],
          :share_access_locked => options['share_access_locked'],
          :grant_share_access => options['grant_share_access']
        }
        puts "Create share:\s".color(:whitesmoke) + "OK".color(:green) if @wdmc.add_share( data )
      rescue RestClient::ExceptionWithResponse => e
        e.response.each do |x|
          p x
        end
      end
    end

    desc 'modify [NAME]', 'Modify a share'
    method_option :new_share_name, :aliases => '-n', :desc => 'New name', :type => :string
    method_option :description, :aliases => '-d', :desc => 'Description', :required => false
    method_option :media_serving, :aliases => '-m', :desc => 'Enable media serving', :type => :boolean, :default => true
    method_option :public_access, :aliases => '-p', :desc => 'Enable public access', :type => :boolean, :default => false
    method_option :remote_access, :aliases => '-r', :desc => 'Enable remote access', :type => :boolean, :default => true
    def modify( name )
      share_exists = @wdmc.share_exists?( name )
      abort "\nShare does not exist: ".color(:yellow) + "#{name}".color(:cyan) unless share_exists.include?( name )
      begin
        data = {
          :share_name => name,
          :new_share_name => options['new_share_name'] || name,
          :description => options['description'],
          :media_serving => options['media_serving'],
          :public_access => options['public_access'],
          :remote_access => options['remote_access']
        }
        puts "Modify share:\s".color(:whitesmoke) + "OK".color(:green) if @wdmc.modify_share( data )
      rescue RestClient::ExceptionWithResponse => e
        puts e.response
      end
    end

    desc 'delete [NAME]', 'Delete a share'
    method_option :force, :aliases => '-f', :desc => 'force (caution!)', :type => :boolean
    def delete( name )
      share_exists = @wdmc.share_exists?( name )
      abort "\nShare does not exist: ".color(:yellow) + "#{name}".color(:cyan) unless share_exists.include?( name )
      unless options['force']
        puts "\nDeleting this share will delete all content and configuration settings within the share!".color(:orange)
        puts "Are you sure you want to delete:\s".color(:orange) + "#{name}".color(:whitesmoke)
        return unless yes?("DELETE? (yes/no):")
      end
      puts "Delete share:\s".color(:whitesmoke) + "OK".color(:green) if @wdmc.delete_share( name )
    end

    desc 'acl', 'Share access'
    subcommand "acl", Acl

  end
end
