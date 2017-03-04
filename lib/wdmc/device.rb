module Wdmc
  class Device < Thor
    include Enumerable

    def initialize(*args)
      @wdmc = Wdmc::Client.new
      @device_description = @wdmc.device_description
      @system_information = @wdmc.system_information
      @firmware = @wdmc.firmware
      @shares = @wdmc.all_shares
      @network = @wdmc.network
      @system_state = @wdmc.system_state
      super
    end

    desc 'summary', 'Complete device overview'
    def summary
      info
      puts
      firmware
      puts
      usage
      puts
      state
      puts
      network
    end

    desc 'firmware', 'Firmware information'
    def firmware
      puts "Firmware".upcase.color(:magenta)
      puts "\sFW Version\t\t: ".color(:whitesmoke) + @firmware[:current_firmware][:package][:version]
      if @firmware[:firmware_update_available][:available] == 'false'
        puts "\s\s- Updates available\t: ".color(:whitesmoke) + @firmware[:firmware_update_available][:available].color(:green)
      else
        puts "\s\s- Updates available\t: ".color(:whitesmoke) + @firmware[:firmware_update_available][:available].color(:orange)
      end
      if @firmware[:upgrades][:available] == 'false'
        puts "\s\s- Upgrades available\t: ".color(:whitesmoke) + @firmware[:upgrades][:available].color(:green)
      else
        puts "\s\s- Upgrades available\t: ".color(:whitesmoke) + @firmware[:upgrades][:available].color(:orange)
      end
    end

    desc 'info', 'Basic information'
    def info
      puts "Device Information".upcase.color(:magenta)
      puts "\sDevice Name\t\t: ".color(:whitesmoke) + @device_description['machine_name']
      puts "\sModel / Number\t\t: ".color(:whitesmoke) + "#{@system_information[:model_name]} " + @system_information[:model_number]
      puts "\sSerial Number\t\t: ".color(:whitesmoke) + @system_information[:serial_number]
      puts "\sDrive Number Serial\t: ".color(:whitesmoke) + @system_information[:master_drive_serial_number]
      puts "\sCapacity\t\t: ".color(:whitesmoke) + @system_information[:capacity]
      puts "\sShares\t\t\t: ".color(:whitesmoke) + @shares.size.to_s
    end

    desc 'usage', 'Device usage'
    def usage
      usage = @wdmc.storage_usage
      free = usage[:size].to_i - usage[:usage].to_i
      puts "Device Usage".upcase.color(:magenta)
      puts "\sCapacity\t\t: ".color(:whitesmoke) + Filesize.from("#{usage[:size]} B").to_s('GB')
      puts "\sFree\t\t\t: ".color(:whitesmoke) + Filesize.from("#{free} B").to_s('GB')
      puts "\sUsage\t\t\t: ".color(:whitesmoke) + Filesize.from("#{usage[:usage]} B").to_s('GB')
      puts "\s\s- Videos\t\t: ".color(:whitesmoke) + Filesize.from("#{usage[:video]} B").to_s('GB') if usage[:video].to_i > 0
      puts "\s\s- Photos\t\t: ".color(:whitesmoke) + Filesize.from("#{usage[:photo]} B").to_s('GB') if usage[:photo].to_i > 0
      puts "\s\s- Music\t\t: ".color(:whitesmoke) + Filesize.from("#{usage[:music]} B").to_s('GB') if usage[:music].to_i > 0
    end

    desc 'network', 'Device network information'
    def network
      puts "Network Configuration".upcase.color(:magenta)
      puts "\sInterface\t\t: ".color(:whitesmoke) + @network[:ifname]
      puts "\sType\t\t\t: ".color(:whitesmoke) + @network[:iftype]
      puts "\sProtocol\t\t: ".color(:whitesmoke) + @network[:proto]
      puts "\sIP Address\t\t: ".color(:whitesmoke) + @network[:ip]
      puts "\sMAC Address\t\t: ".color(:whitesmoke) + @system_information[:mac_address]
      puts "\sNetmask\t\t: ".color(:whitesmoke) + @network[:netmask]
      puts "\sGateway\t\t: ".color(:whitesmoke) + @network[:gateway]
      puts "\sDNS Servers\t\t: ".color(:whitesmoke) + @network[:dns0] + @network[:dns1] + @network[:dns2]
    end

    desc 'state', 'Device state'
    def state
      puts "Device State".upcase.color(:magenta)
      puts "\sStatus\t\t\t: ".color(:whitesmoke) + @system_state[:status]
      puts "\sTemperature\t\t: ".color(:whitesmoke) + @system_state[:temperature].color(:green) if @system_state[:temperature] == 'good'
      puts "\sTemperature\t\t: ".color(:whitesmoke) + @system_state[:temperature].color(:orange) if @system_state[:temperature] == 'bad'
      puts "\sS.M.A.R.T\t\t: ".color(:whitesmoke) + @system_state[:smart].color(:green) if @system_state[:smart] == 'good'
      puts "\sS.M.A.R.T\t\t: ".color(:whitesmoke) + @system_state[:smart].color(:orange) if @system_state[:smart] == 'bad'
      puts "\sVolume\t\t\t: ".color(:whitesmoke) + @system_state[:volume].color(:green) if @system_state[:volume] == 'good'
      puts "\sVolume\t\t\t: ".color(:whitesmoke) + @system_state[:volume].color(:orange) if @system_state[:volume] == 'bad'
      puts "\sFree Space\t\t: ".color(:whitesmoke) + @system_state[:free_space].color(:green) if @system_state[:free_space] == 'good'
      puts "\sFree Space\t\t: ".color(:whitesmoke) + @system_state[:free_space].color(:orange) if @system_state[:free_space] == 'bad'
      puts "\sReported Status\t: ".color(:whitesmoke) + @system_state[:reported_status].color(:green) if @system_state[:reported_status] == 'good'
      puts "\sReported Status\t: ".color(:whitesmoke) + @system_state[:reported_status].color(:orange) if @system_state[:reported_status] == 'bad'
    end
  end
end
