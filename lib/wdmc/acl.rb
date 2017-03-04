require 'wdmc/shares'

module Wdmc
  class Acl < Thor
    include Enumerable

    def initialize(*args)
      @wdmc = Wdmc::Client.new
      super
    end

    desc 'get [SHARE NAME]', 'Get shares acl'
    def get( name )
      share_exists = @wdmc.share_exists?( name )
      abort "\nShare does not exist: ".color(:yellow) + "#{name}".color(:cyan) unless share_exists.include?( name )
      Wdmc::Share.new.show( name )
    end

    desc 'set [SHARE NAME]', 'Set ACL for a share'
    method_option :user, :aliases => '-u', :desc => 'Username', :type => :string, :required => true
    method_option :access, :aliases => '-a', :desc => 'Can be RO (Read only) or RW (READ/WRITE)', :type => :string, :required => true
    def set( name )
      share_exists = @wdmc.share_exists?( name )
      abort "\nShare does not exist: ".color(:yellow) + "#{name}".color(:cyan) unless share_exists.include?( name )
      begin
        data = {
          'share_name' => name,
          'username' => options['user'],
          'access' => options['access']
        }
        puts "Set ACL:\s".color(:whitesmoke) + "OK".color(:green) if @wdmc.set_acl( data )
        share = @wdmc.get_acl( name )
        share['share_access'].map do |access|
          puts "\s- Username\t:\s".color(:whitesmoke) + access['username']
          puts "\s- User ID\t:\s".color(:whitesmoke) + access['user_id']
          puts "\s- Access\t:\s".color(:whitesmoke) + access['access'].color(:green) if access['access'] == 'RW'
          puts "\s- Access\t:\s".color(:whitesmoke) + access['access'].color(:yellow) if access['access'] == 'RO'
          puts
        end
      rescue RestClient::ExceptionWithResponse => e
        puts e.response
      end
    end

    desc 'modify [SHARE NAME]', 'Edit ACL for a share'
    method_option :user, :aliases => '-u', :desc => 'Username', :type => :string, :required => true
    method_option :access, :aliases => '-a', :desc => 'Can be RO (Read only) or RW (READ/WRITE)', :type => :string, :required => true
    def edit( name )
      share_exists = @wdmc.share_exists?( name )
      abort "\nShare does not exist: ".color(:yellow) + "#{name}".color(:cyan) unless share_exists.include?( name )
      begin
        data = {
          'share_name' => name,
          'username' => options['user'],
          'access' => options['access']
        }
        puts "Modify ACL:\s".color(:whitesmoke) + "OK".color(:green) if @wdmc.modify_acl( data )
        share = @wdmc.get_acl( name )
        share['share_access'].map do |access|
          puts "\s- Username\t:\s".color(:whitesmoke) + access['username']
          puts "\s- User ID\t:\s".color(:whitesmoke) + access['user_id']
          puts "\s- Access\t:\s".color(:whitesmoke) + access['access'].color(:green) if access['access'] == 'RW'
          puts "\s- Access\t:\s".color(:whitesmoke) + access['access'].color(:yellow) if access['access'] == 'RO'
          puts
        end
      rescue RestClient::ExceptionWithResponse => e
        puts e.response
      end
    end

    desc 'remove [SHARE NAME]', 'Delete ACL for a share'
    method_option :user, :aliases => '-u', :desc => 'Username', :type => :string, :required => true
    method_option :force, :aliases => '-f', :desc => 'force (caution!)', :type => :boolean
    def delete( name )
      share_exists = @wdmc.share_exists?( name )
      abort "\nShare does not exist: ".color(:yellow) + "#{name}".color(:cyan) unless share_exists.include?( name )
      begin
        data = {
          'share_name' => name,
          'username' => options['user']
        }
        unless options['force']
          puts "\nYou are going to delete #{options['access']} access for user #{options['user']} to #{name}".color(:orange)
          return unless yes?("DELETE? (yes/no): ")
        end
        puts "Remove ACL:\s".color(:whitesmoke) + "OK".color(:green) if @wdmc.delete_acl( data )
        share = @wdmc.get_acl( name )
        share['share_access'].map do |access|
          puts "\s- Username\t:\s".color(:whitesmoke) + access['username']
          puts "\s- User ID\t:\s".color(:whitesmoke) + access['user_id']
          puts "\s- Access\t:\s".color(:whitesmoke) + access['access'].color(:green) if access['access'] == 'RW'
          puts "\s- Access\t:\s".color(:whitesmoke) + access['access'].color(:yellow) if access['access'] == 'RO'
          puts
        end
      rescue RestClient::ExceptionWithResponse => e
        puts e.response
      end
    end

  end
end
