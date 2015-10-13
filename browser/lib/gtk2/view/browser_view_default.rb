module GMVCApp
  class BrowserViewDefault < GMVC::View
    
    def initialize(*args)
      super
=begin
      @entry = self.attach_widget_to_attribute('entry', 'entry', :text=)
      @entry.editable = false
=end
    end
    def about_to_close
      true
    end
  end
end
