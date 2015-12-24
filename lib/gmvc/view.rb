module GMVC
  class View < XMVC::View
    attr_reader :builder
    def initialize(*args)
      super
      @attached_widgets = Hash.new
      @builder = @controller.builder
      @gtk_window = @builder.get_object(@name)
      @builder.attach_to_object(@gtk_window, self)
      @controller.connect_signals
      @gtk_window.signal_connect('delete_event') { self.on_delete_event }
      @gtk_window.signal_connect('destroy') { self.on_destroy }
      self.init_window
    end
    def init_window
    end
    def show(*flags)
      flags = [:show] if flags.empty?
      flags.each do |flag|
        case flag
        when :show
          @gtk_window.show
        end
      end
    end
    def detach_widgets_from_attributes
      @attached_widgets.each_key do |object, attribute|
        @model.set_attribute_reaction(attribute, object, nil)
      end
    end
    def attach_widget_to_attribute(widget, attribute, assignment_block)
      if widget.is_a?(String)
        object = @builder.get_object(widget)
      else
        object = widget
      end
      if assignment_block.is_a?(Symbol)
        block = lambda { |value| object.method(assignment_block).call(value) }
      else
        block = assignment_block
      end
      return nil if !object
      @model.set_attribute_reaction(attribute, object, block)
      @attached_widgets[[object, attribute]] = block
      object
    end

    def about_to_close
      puts "about_to_close"
      true # return true if its ok to close the window
    end

    def close
      return if !self.about_to_close
      @gtk_window.destroy
    end

    def on_delete_event
      puts "on_delete_event"
      !self.about_to_close
    end

    def on_destroy
      self.detach_widgets_from_attributes
      puts "on_destroy"
    end
    def message_dialog(argumentHash = nil)
      hash = {:parent => @gtk_window}
      if !argumentHash.nil?
        argumentHash.each do |key, value|
          hash[key] = value
        end
      end
      hash[:type] ||= :info
      hash[:title] ||= $application.name
      if hash[:buttons_type].nil?
        if hash[:button_array].nil?
          hash[:buttons_type] = :ok
        else
          hash[:buttons_type] = :none
        end
      end
      hash[:button_array] ||= []
      dialog = Gtk::MessageDialog.new(hash)
      dialog.title = hash[:title]
      hash[:button_array].each do |symbol|
        dialog.add_button(symbol.to_s.capitalize, symbol)
      end
      answer = dialog.run
      dialog.destroy
      return answer
    end
    def message_box(message_text, title = $application.name, type = :info)
      answer = self.message_dialog({:message => message_text, :title => title, :type => type})
      if answer == Gtk::ResponseType::DELETE_EVENT
        return Gtk::ResponseType::OK
      end
      return answer
    end
    def message_confirm(message_text, title = $application.name)
      hash = {:message => message_text,
              :title => title,
              :type => :question,
              :button_array => [:yes, :no]}
      begin
        answer = self.message_dialog(hash)
      end while answer != Gtk::ResponseType::DELETE_EVENT
      return answer
    end
    def message_confirm_with_cancel(message_text, title = $application.name)
      hash = {:message => message_text,
              :title => title,
              :type => :question,
              :button_array => [:yes, :no, :cancel]}
      answer = self.message_dialog(hash)
      if answer == Gtk::ResponseType::DELETE_EVENT
        return Gtk::ResponseType::CANCEL
      end
      return answer
    end
  end
end
