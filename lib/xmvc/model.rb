module GMVC
  class Model
    def initialize
      @views = Set.new
    end
    def register_view(view)
      @views << view
      true
    end
    def unregister_view(view)
      !@views.delete?(view).nil?
    end
  end
end