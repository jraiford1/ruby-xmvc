module GMVCApp
  class ClassHeirarchyBrowserController < GMVC::Controller
    
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
  end
end