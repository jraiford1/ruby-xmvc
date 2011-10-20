module GMVC
  class Controller
    attr_accessor :model
    
    def self.open
      self.new.open
    end
    def open
      self.open_view(self.default_view_class)
    end
    def open_view(view_class)
      @view = view_class.new(self, @model)
      self          # return self
    end
  end
end