module ProtoCool::ResourceFu::HelperDelegation
  
  class << self
    def delegation_args(calling_controller, delegator, options = {})
      unpacked = {:delegator => delegator.to_s}
      unpacked[:delegator_singular] = (options[:singular] || delegator.to_s.singularize).to_s

      if controller_option = options[:controller]
        unpacked[:controller_path] = controller_option.respond_to?(:controller_path) ? controller_option.controller_path : controller_option.to_s
      else
        unpacked[:controller_path] = calling_controller.controller_path
      end

      if [options[:to], options[:name_prefix]].all?(&:blank?)
        raise ArgumentError, "Helper delegation needs options for either :to or :name_prefix"
      end
      
      unpacked[:delegated] = (options[:to] || unpacked[:delegator]).to_s
      unpacked[:delegated_singular] = (options[:to_singular] || unpacked[:delegated].singularize).to_s
      unpacked[:name_prefix] = options[:name_prefix].to_s
      unpacked
    end
  end

  def delegate_resources_helpers(delegator, option_args = {})
    options = ProtoCool::ResourceFu::HelperDelegation.delegation_args(self, delegator, option_args)

    match_plural = %r|^(formatted_){0,1}#{options[:name_prefix]}(.+){0,1}(#{options[:delegated]})$|
    match_singular = %r|^(formatted_){0,1}#{options[:name_prefix]}(.+){0,1}(#{options[:delegated_singular]})$|

    ActionController::Routing::Routes.named_routes.select {|name,route| route.requirements[:controller] == options[:controller_path]}.each do |name, route|
      if match = match_plural.match(name.to_s)
        delegate_url_helpers (match[1..-2] << options[:delegator]).join, :to => name
      elsif match = match_singular.match(name.to_s)
        delegate_url_helpers (match[1..-2] << options[:delegator_singular]).join, :to => name
      else
        logger.debug "HelperDelegation: Unable to figure out how to delegate resource #{options[:delegator].inspect} for route #{name.inspect}"
      end
    end
    nil
  end

  def delegate_resource_helpers(delegator, option_args = {})
    options = ProtoCool::ResourceFu::HelperDelegation.delegation_args(self, delegator, option_args)

    match_plural = %r|^(formatted_){0,1}#{options[:name_prefix]}(.+){0,1}(#{options[:delegated]})$|

    ActionController::Routing::Routes.named_routes.select {|name,route| route.requirements[:controller] == options[:controller_path]}.each do |name, route|
      if match = match_plural.match(name.to_s)
        delegate_url_helpers (match[1..-2] << options[:delegator]).join, :to => name
      else
        logger.debug "HelperDelegation: Unable to figure out how to delegate resource #{options[:delegator].inspect} for route #{name.inspect}"
      end
    end
    nil
  end

  def delegate_url_helpers(*delegations)
    options = delegations.pop
    delegated = delegations.pop

    case
    when delegated.nil? && Class === options[:for]
      options[:for].delegated_url_helpers.each do |new_helper, delegated_helper|
        delegate_url_helper(new_helper, delegated_helper)
      end
    when delegated && options[:to]
      ['_path', '_url'].each do |helper_type|
        delegate_url_helper(delegated.to_s + helper_type, options[:to].to_s + helper_type)
      end
    else
      raise ArgumentError, "Helper delegation expects arguments like ':foo, :to => :bar' or ':for => Controller'"
    end
  end

  def delegate_url_helper(new_helper, delegated_helper)
    module_eval(<<-EOS, "(__DELEGATED_HELPERS_#{new_helper.to_s}__)", 1)
      def #{new_helper.to_s}(*args)
        #{delegated_helper.to_s}(*args)
      end
      helper_method #{new_helper.to_sym.inspect}
      protected #{new_helper.to_sym.inspect}
    EOS
    (@delegated_url_helpers ||= {})[new_helper.to_s] = delegated_helper.to_s
  end

  def delegated_url_helpers
    (@delegated_url_helpers ||= {}).dup
  end

end
