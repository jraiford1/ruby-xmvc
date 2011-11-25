module XMVC
  class Model
    
    # Initialize the new model instance
    def initialize
      @views = Set.new
    end
    
    # Register an object to receive change events
    def register(obj)
      @ << view
      true
    end
    def unregister_view(view)
      !@views.delete?(view).nil?
    end
  end
end