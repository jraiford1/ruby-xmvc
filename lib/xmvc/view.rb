module XMVC
  class View
    attr_reader :model, :controller
    def initialize(model, controller, name)
      @model = model
      @model.add_observer(self)
      @controller = controller
      @name = name
    end
    def update(*args)
      self.refresh
    end
    def refresh
      
    end
    def show(*flags)
      
    end
    def visible?
      false
    end
    def hide
      
    end
  end
end