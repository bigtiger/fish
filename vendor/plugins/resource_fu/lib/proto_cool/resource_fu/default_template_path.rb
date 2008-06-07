# This mix-in allows you to override the location of your 
# controller's default templates.  

module ProtoCool::ResourceFu::DefaultTemplatePath
  class << self
    def included(base)
      unless base.respond_to?(:default_template_path)
        base.extend ClassMethods
        base.send :include, InstanceMethods
        ActionView::Partials.send :include, PartialMethods
      end
    end
  end

  module ClassMethods
    def default_template_path
      @default_template_path ||= controller_path
    end
    
    def set_default_template_path(location)
      @default_template_path = location
    end
  end
  
  module InstanceMethods
    class << self
      def included(base)
        base.class_eval do
          alias_method_chain :default_template_name, :resource_fu
          private :default_template_name, :default_template_name_without_resource_fu, 
                  :default_template_name_with_resource_fu, :template_path_includes_default?
        end
      end
    end

    # a rewrite of the standard default_template_name but this one
    # uses default_template_path instead of controller_path and
    def default_template_name_with_resource_fu(action_name = self.action_name)
      if action_name
        action_name = action_name.to_s
        if action_name.include?('/') && template_path_includes_default?(action_name)
          action_name = strip_out_controller(action_name)
        end
      end
      "#{self.class.default_template_path}/#{action_name}"
    end
    
    def template_path_includes_default?(path)
      self.class.default_template_path.split('/')[-1] == path.split('/')[0]
    end
  end
  
  module PartialMethods
    class << self 
      def included(base)
        base.class_eval do
          alias_method_chain :partial_pieces, :resource_fu
          private :partial_pieces, :partial_pieces_without_resource_fu, :partial_pieces_with_resource_fu
        end
      end
    end
    
    def partial_pieces_with_resource_fu(partial_path)
      if partial_path.include?('/')
        return File.dirname(partial_path), File.basename(partial_path)
      else
        return controller.class.default_template_path, partial_path
      end
    end
  end
end
