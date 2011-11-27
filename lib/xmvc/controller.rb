module XMVC
  class Controller
    attr_reader :view_names, :model
    
    def initialize(model)
      @model = model
      @view_names = Array.new
      @views = Hash.new
      @visible = false
    end
    
    def hide
      
    end
    
    
    # Change the view, maintaining the visibility of the window
    def change_view(view_name = @model.default_view_name)
      return if @view and @view.name == view_name
      view_name = @controller.view_names.first if !view_name
      @view.hide if @view
      @view = @views[view_name] ||= self.get_view(view_name)
      @view.show if self.visible?
    end
    
    # Show the current view using the supplied flags (:modal, :maximized, etc)
    def show(*flags)
      self.open if @view.nil?
      @view.show(*flags)
      @visible = @view.visible?
    end
  end
end