module GMVCApp
  class ClassHeirarchyBrowserController < GMVC::Controller

    def on_quit_action_activate
      puts "Quit!"
      @view.close
      Gtk.main_quit
    rescue Exception => e
      self.exception_handler(e,$!)
    end
    def on_code_save_action_activate
      puts "TODO: Save the code!"
    rescue Exception => e
      self.exception_handler(e,$!)
    end
    def on_rb_class_clicked
      @rb_class ||= @builder.get_object("rb_class")
      return true if !@rb_class.active?
      self.update_methods
    rescue Exception => e
      self.exception_handler(e,$!)
    end
    def save_changes
      puts "save changes"
      true
    rescue Exception => e
      self.exception_handler(e,$!)
    end
    def on_rb_instance_clicked
      @rb_instance ||= @builder.get_object("rb_instance")
      return true if !@rb_instance.active?
      self.update_methods
    rescue Exception => e
      self.exception_handler(e,$!)
    end
    def on_class_selected(selection, treestore, path, currently_selected)
      class_iter = treestore.get_iter(path)
      return true if class_iter.nil?
      return false if !self.save_changes
      class_info = class_iter[0]
      @view.class_info = class_info
      if !currently_selected
        self.update_methods
      else
        #@view.unregister_methods_view_for_class(treeview, class_iter, view.methods_selector)
      end
      true
    rescue Exception => e
      self.exception_handler(e,$!)
      false
    end
    def update_methods
      @view.methods_list.model = @view.method_liststore(@view.class_info)
    end
    def on_method_selected(selection, methods_model, path, currently_selected)
      method_iter = methods_model.get_iter(path)
      puts method_iter #if currently_selected
      return true if method_iter.nil?
      return false if !self.save_changes
      method_info = method_iter[0]
      class_info = method_info.class_info
      if !currently_selected
        puts method_info.real_method
        @view.source_code.buffer.text = method_info.real_method.source
      end
      true
    rescue Exception => exception
      @view.source_code.buffer.text = exception.backtrace.join("\n")
      true
    end
    def exception_handler(exception, mtd)
      puts "Error during processing: #{mtd}"
      puts "Backtrace:\n\t#{exception.backtrace.join("\n\t")}"
    end
  end
end
