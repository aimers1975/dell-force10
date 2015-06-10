Puppet::Type.newtype(:force10_exec) do
  @doc = "A generic way to execute various commands on Dell Force10 switch."

  def self.newcheck(name, options = {}, &block)
    @checks ||= {}
    check = newparam(name, options, &block)
    @checks[name] = check
  end

  def self.checks
    @checks.keys
  end

  newparam(:name) do
    desc "Name, can be any unique name"
    isnamevar
  end

  newparam(:command) do
    desc "This is command String need to execute"
    validate do |command|
      raise ArgumentError, "Command must be a String, got value of class #{command.class}" unless command.is_a? String
    end
  end

  newparam(:context) do
    desc "The context denotes mode of the switch, on which mode the command has to execute"
    desc "Command String"
    isrequired
    newvalues(:exec, :conf)
  end

  newcheck(:refreshonly) do
    desc "This Flag denotes only refresh or execute command"
    newvalues(:true, :false)
    def check(value)
      if value == :true
        false
      else
        true
      end
    end
  end

  newproperty(:returns, :event => :executed_command) do |property|
    munge do |value|
      value.to_s
    end

    def event_name
      :executed_command
    end

    defaultto "#"

    def change_to_s(currentvalue, newvalue)
      "executed successfully"
    end

    def retrieve
      if @resource.check_all_attributes
        return :notrun
      else
        return self.should
      end
    end

    def sync
      event = :executed_command
      out = provider.run(self.resource[:command], self.resource[:context])
      unless out.match(self.should)
        self.fail("output of command: #{self.resource[:command]} does not match expected return value: #{self.should}")
      end
      event
    end
  end

  @isomorphic = false

  def self.instances
    []
  end

  def check_all_attributes(refreshing = false)
    self.class.checks.each { |check|
      next if refreshing and check == :refreshonly
      if @parameters.include?(check)
        val = @parameters[check].value
        val = [val] unless val.is_a? Array
        val.each do |value|
          return false unless @parameters[check].check(value)
        end
      end
    }

    true
  end

  def refresh
    if self.check_all_attributes(true)
      provider.run(self[:command], self[:context])
    end
  end
end
