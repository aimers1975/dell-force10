require 'puppet_x/force10/model'
require 'puppet_x/force10/model/portchannel'

module PuppetX::Force10::Model::Portchannel::Base
  def self.register(base)
    portchannel_scope = /^(L*\s*(\d+)\s+(.*))/
    general_scope = /(^Port-channel (\d+).*)\s+/m
    portchannelval = base.name

    base.register_scoped :ensure, portchannel_scope do
      match do |txt|
        unless txt.nil?
          txt.match(/\S+/) ? :present : :absent
        else
          :absent
        end
      end
      cmd 'show interface port-channel brief'
      default :absent
      add { |*_| }
      remove { |*_| }
    end

    base.register_scoped :mtu, general_scope do

      match do |txt|
          paramsarray=txt.match(/^MTU (\d+)/)
          if paramsarray.nil?
            param1 = :absent
          else
            param1 = paramsarray[1]
          end
          param1
      end

      cmd "show interface port-channel #{portchannelval}"
      default :absent
      add do |transport, value|
        transport.command("mtu #{value}")
      end
      remove { |*_| }
    end

    base.register_scoped :shutdown, general_scope do
      
      match do |txt|
          paramsarray=txt.match(/^Port-channel (\d+) is up/)
          if paramsarray.nil?
            param1 = :true
          else
            param1 = :false
          end
          param1
      end


      cmd "show interface port-channel #{portchannelval}"
      default :absent
      add do |transport, value|
        if value == :false
          transport.command("no shutdown")
        else
          transport.command("shutdown")
        end
      end
      remove { |*_| }
    end


    base.register_scoped :switchport, portchannel_scope do

      match do |txt|
          paramsarray=txt.match(/L2/)
          if paramsarray.nil?
            param1 = :false
          else
            param1 = :true
          end
          param1
      end

      cmd "show interfaces port-channel brief"
      add do |transport, value|
        if value == :false
          transport.command("no switchport")
        else
          transport.command("portmode hybrid")
          transport.command("switchport")
        end
      end
      remove { |*_| }
    end

    base.register_scoped :fip_snooping_fcf, general_scope do
      match do |txt|
        paramsarray=txt.match(/fip-snooping port-mode fcf/)
        if paramsarray.nil?
          param1 = :true
        else
          param1 = :false
        end
        param1
      end

      cmd "show interface port-channel #{portchannelval}"
      default :absent
      add do |transport, value|
        if value == :true
          transport.command("fip-snooping port-mode fcf")
        else
          transport.command("no fip-snooping port-mode fcf")
        end
      end
      remove { |*_| }
    end


      

    base.register_scoped :desc, general_scope do
      match do |txt|
          paramsarray=txt.match(/^Description: (.*)/)
          if paramsarray.nil?
            param1 = :absent
          else
            param1 = paramsarray[1]
          end
          param1
      end

      cmd "show interface port-channel #{portchannelval}"
      add do |transport, value|
        transport.command("desc #{value}")
      end
      remove { |*_| }
    end
    
    base.register_scoped :fcoe_map, general_scope do
      match do |txt|
        paramsarray=txt.match(/^fcoe-map\s+(\S+)/)
        if paramsarray.nil?
          param1 = :absent
        else
          param1 = paramsarray[1]
        end
        param1
      end

      cmd "show running-config interface port-channel #{portchannelval}"
      add do |transport, value|
        transport.command("fcoe-map #{value}")
      end
      remove { |*_| }
    end

    base.register_scoped :vltpeer, portchannel_scope do
      match do |txt|
        paramsarray=txt.match(/^\d+\s+(\w2)\s+\w+/)
        if paramsarray.nil?
          param1 = true
        else
          param1 = false
        end
        param1
      end

      cmd "show interface port-channel #{portchannelval}"
      add do |transport, value|
        if value == :true
          transport.command("vlt-peer-lag po#{portchannelval}")
        end
      end
      remove { |*_| }
    end

  end
end
