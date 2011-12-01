module XMVC
  class Model
    
    # Initialize the new model instance
    def initialize
      #@views = Hash.new
    end
    def default_view_name
      nil
    end
    # Register an object to receive change events
    def register(obj)
      @views << obj
      true
    end
    def unregister_view(view)
      !@views.delete?(view).nil?
    end
  end
end