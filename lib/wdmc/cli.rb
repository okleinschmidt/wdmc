require 'wdmc'
require 'json'

module Wdmc
  class CLI < Thor

    desc 'sysinfo', 'Device information'
    def sysinfo
      Wdmc::Device.new.summary
    end

    desc 'user', 'User commands'
    subcommand "user", User

    desc 'acl', 'Fileshare ACLs'
    subcommand "acl", Acl

    desc 'share', 'Fileshare commands'
    subcommand "share", Share

    desc 'tm', 'TimeMachine commands'
    subcommand "tm", TimeMachine

    desc 'device', 'Device commands'
    subcommand "device", Device

    desc 'version', 'Version information'
    def version
      puts Wdmc::VERSION
    end

  end
end
