# This is  force 10 interface module.
require 'puppet/util/network_device/ipcalc'
require 'puppet/util/network_device/dell_ftos/model'
require 'puppet/util/network_device/dell_ftos/model/base'
require 'puppet/util/network_device/dell_ftos/model/scoped_value'

class Puppet::Util::NetworkDevice::Dell_ftos::Model::Interface < Puppet::Util::NetworkDevice::Dell_ftos::Model::Base

  attr_reader :params, :name
  def initialize(transport, facts, options)
    super(transport, facts)
    # Initialize some defaults
    @params         ||= {}
    @name           = options[:name] if options.key? :name

    # Register all needed Modules based on the availiable Facts
    register_modules
  end

  def mod_path_base
    return 'puppet/util/network_device/dell_ftos/model/interface'
  end

  def mod_const_base
    return Puppet::Util::NetworkDevice::Dell_ftos::Model::Interface
  end

  def param_class
    return Puppet::Util::NetworkDevice::Dell_ftos::Model::ScopedValue
  end

  def register_modules
    register_new_module(:base)
  end

  def before_update(params_to_update=[])
    transport.command("show interfaces #{@name}")do |out|
      if out =~/Error:\s*(.*)/
        Puppet.debug "errror msg ::::#{$1}"
        Puppet.debug("Wait for 1 minute before re-validating")
        sleep(60)
        new_out = transport.command("show interfaces #{@name}")
        raise "The entered interface does not exist. Enter the correct interface." if new_out =~/Error:\s*(.*)/
      end
    end
    super
    # Need to remove port from all vlans if we want to change the portmode
    if params_to_update.collect{|param| param.name}.include?(:portmode)
      Puppet.info("Removing all vlans for #{name} so portmode can be set.")
      transport.command("interface range vlan 1-4094")
      transport.command("no tagged #{name}")
      transport.command("no untagged #{name}")
      transport.command("exit")
    end
    transport.command("interface #{@name}", :prompt => /\(conf-if-\S+\)#\z/n)
  end

  def after_update
    transport.command("exit")
    super
  end

end
