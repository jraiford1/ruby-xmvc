require 'observer'

module XMVC
  class Model
    include Observable
    # Initialize the new model instance
    def initialize
      @attribute_reactions = Hash.new
    end
    
    def [] attribute_name
      self.instance_variable_get("@attr_#{attribute_name}")
    end
    
    def []= attribute_name, new_value
      self.instance_variable_set("@attr_#{attribute_name}", new_value)
      procs = @attribute_reactions[attribute_name]
      return if !procs
      procs.each_value { |proc| proc.call(new_value) }
    end
    
    def set_attribute_reaction(attribute_name, key, &proc)
      reaction_list = @attribute_reactions[attribute_name] ||= Hash.new
      return clear_attribute_reaction(attribute_name, key) if !proc
      reaction_list[key] = proc
    end
    
    def clear_attribute_reaction(attribute_name, key)
      reaction_list = @attribute_reactions[attribute_name] ||= Hash.new
      reaction_list.delete(key)
    end
    def default_view_name
      nil
    end
    
  end
end