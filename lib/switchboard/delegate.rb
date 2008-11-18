class Module
  def delegate(*methods)
    options = methods.pop
    unless options.is_a?(Hash) && to = options[:to]
      raise ArgumentError, "Delegation needs a target. Supply an options hash with a :to key as the last argument (e.g. delegate :hello, :to => :greeter)."
    end

    prefix = options[:prefix] && "#{options[:prefix] == true ? to : options[:prefix]}_"
    with = options[:with] || []

    methods.each do |method|
      module_eval(<<-EOS, "(__DELEGATION__)", 1)
        def #{prefix}#{method}(*args, &block)
          args += [#{with * ", "}]
          #{to}.__send__(#{method.inspect}, *args, &block)
        end
      EOS
    end
  end
end