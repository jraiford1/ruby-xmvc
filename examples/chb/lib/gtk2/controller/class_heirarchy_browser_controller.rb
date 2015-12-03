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
      return true if @current_method_info.nil?
      if @view.source_code.buffer.text == @current_method_info.source_code
        puts "no change"
        true
      else
        GMVC::Prompter.display("Save Changes?")
        puts "save changes"
        false
      end
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
    def on_class_about_to_select(class_tree)
      class_iter = class_tree.selection.selected
      return true if class_iter.nil?
      return false if !self.save_changes
      false
    end

    def on_class_selected(selection, treestore, path, currently_selected)
      class_iter = selection.selected
      return true if class_iter.nil?
      return false if !self.save_changes
      @current_method_info = nil
      class_info = class_iter[0]
      @view.class_info = class_info
      if !currently_selected
        @current_class_info = class_info
        self.update_methods
        @view.source_code.buffer.text = self.class_definition(@current_class_info)
      else
        #@view.unregister_methods_view_for_class(treeview, class_iter, view.methods_selector)
      end
      true
    rescue Exception => e
      self.exception_handler(e,$!)
      false
    end
    def class_definition(class_info)
      if class_info.nil?
        ''
      else
        if class_info.superclass.nil?
          [
            "  class #{class_info.class_name}",
            "  end"
          ].join("\n") + "\n"
        else
          [
            "  class #{class_info.class_name} < #{class_info.superclass.class_name}",
            "  end"
          ].join("\n") + "\n"
        end
      end
    end
    def update_methods
      @view.methods_list.model = @view.method_liststore(@view.class_info)
    end
    def on_method_selected(selection, methods_model, path, currently_selected)
      method_iter = selection.selected
      puts method_iter #if currently_selected
      return true if method_iter.nil?
      return false if !self.save_changes
      method_info = method_iter[0]
      class_info = method_info.class_info
      if !currently_selected
        puts method_info.real_method
        @current_method_info = method_info
        @view.source_code.buffer.text = method_info.source_code
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
