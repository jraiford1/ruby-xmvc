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
      if @view.source_code.buffer.text != @current_method_info.source_code
        should_save = @view.message_confirm_with_cancel("Save Changes?")
        case should_save
          when Gtk::ResponseType::YES
            puts "save changes"
          when Gtk::ResponseType::NO
            return true
          else
            return false
        end
      end
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
    def about_to_select_class(selection, treestore, path, currently_selected)
      return true if !currently_selected
      class_iter = selection.selected
      return true if class_iter.nil?
      return false if !self.save_changes
      true
    end
    def class_selected(selection, treestore)
      class_iter = selection.selected
      return true if class_iter.nil?
      @current_method_info = nil
      class_info = class_iter[0]
      @view.class_info = class_info
      @current_class_info = class_info
      self.update_methods
      @view.source_code.buffer.text = self.class_definition(@current_class_info)
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
    def about_to_select_method(selection, methods_model, path, currently_selected)
      method_iter = selection.selected
      return true if !currently_selected
      return true if method_iter.nil?
      return false if !self.save_changes
      true
    end
    def method_selected(selection, methods_model)
      method_iter = selection.selected
      return true if method_iter.nil?
      method_info = method_iter[0]
      class_info = method_info.class_info
      @current_method_info = method_info
      @view.source_code.buffer.text = method_info.source_code
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
