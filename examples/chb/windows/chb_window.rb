require_relative '../../lib/gmvc'



class CHBWindow < GMVC::Window
  @@model = CHBModel.new    # All views will share the same model
  def initialize
    @model = @@model
  end
  def default_view_class
    CHBView
  end
  def on_quit_action_activate
    puts "button clicked!"
    @view.close
  end
  def on_class_selected(view, treeview, class_iter, currently_selected)
    return false if !self.save_changes
    if !currently_selected
      @model.register_methods_view_for_class(treeview, class_iter, view.methods_type)
    else
      @model.unregister_methods_view_for_class(treeview, class_iter, view.methods_type)
    end
  end
  def save_changes
    true
  end
end