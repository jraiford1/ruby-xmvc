require 'gtk2'
module GMVC
  class Builder < Gtk::Builder
    # Initialize our extra variables
    def initialize(*args)
      super
      @attached_objects = Hash.new
    end

    def top_windows
      self.objects.select { |obj| obj.kind_of?(Gtk::Window) }
    end
    # Replace the restrictive __connect_signals__ from Gtk::Builder
    def __connect_signals__(connector, object, signal_name, handler_name, connect_object, flags)
      handler_name = canonical_handler_name(handler_name)
      attached_object = @attached_objects[object]

      # Instead of having a single if/elsif statement, we want to be able to
      # ask the connector block to attach the signal even if there is an attached
      # object or a connect_object and no handler was defined
      if attached_object and attached_object.methods.include?(handler_name)
        handler = attached_object.method(handler_name)
      end
      if !handler and connect_object
        handler = connect_object.method(handler_name)
      end
      if !handler
        handler = connector.call(handler_name, object, signal_name)
      end
      unless handler
        $stderr.puts("Undefined handler: #{handler_name}") if $DEBUG
        return
      end

      if flags.after?
        signal_connect_method = :signal_connect_after
      else
        signal_connect_method = :signal_connect
      end

      if handler.arity.zero?
        object.send(signal_connect_method, signal_name) {handler.call}
      else
        object.send(signal_connect_method, signal_name, &handler)
      end
    end

    # Call this prior to connecting signals to attach signals to ruby objects
    def attach_to_object(gobject, object)
      gobject = self.get_object(gobject) if gobject.kind_of?(String)
      if object
        @attached_objects[gobject] = object
      else
        @attached_objects.delete(gobject)
      end
    end

  end
end
