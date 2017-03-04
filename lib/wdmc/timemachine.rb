module Wdmc
  class TimeMachine < Thor
    include Enumerable

    def initialize(*args)
      @wdmc = Wdmc::Client.new
      super
    end

    desc 'get', 'Get TimeMachine configuration'
    def get
      get_tm = @wdmc.get_tm
      puts "Time Machine".upcase.color(:magenta)
      puts "\sBackup Share\t\t: ".color(:whitesmoke) + get_tm[:backup_share]
      puts "\sEnabled\t\t: ".color(:whitesmoke) + get_tm[:backup_enabled].color(:green) if get_tm[:backup_enabled] == 'true'
      puts "\sEnabled\t\t: ".color(:whitesmoke) + get_tm[:backup_enabled].color(:orange) if get_tm[:backup_enabled] == 'false'
      if get_tm[:backup_size_limit] == '0'
        puts "\sSize Limit\t\t: ".color(:whitesmoke) + "unlimited"
      else
        puts "\sSize Limit\t\t: ".color(:whitesmoke) + Filesize.from("#{get_tm[:backup_size_limit]} B").to_s('GB')
      end
    end

    desc 'set', 'Set TimeMachine configuration'
    method_option :backup_size_limit, :aliases => '-s', :desc => 'Size limit [100 GB], default: unlimited', :type => :string, :default => '0GB'
    method_option :backup_enabled, :aliases => '-d', :desc => 'Disable Backup', :type => :boolean, :default => true
    def set( name )
      share_exists = @wdmc.share_exists?( name )
      abort "\nShare does not exist: ".color(:yellow) + "#{name}".color(:cyan) unless share_exists.include?( name )
      data = {
        :backup_enabled => options[:backup_enabled],
        :backup_size_limit => Filesize.from("#{options[:backup_size_limit]}").to_i
      }
      puts "Set TimeMachine:\s".color(:whitesmoke) + "OK".color(:green) if @wdmc.set_tm( data )
    end

  end
end
