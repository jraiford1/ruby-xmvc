module XMVC
  class View
    attr_reader :model, :controller
    def initialize(model, controller)
      @model = model
      @controller = controller
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