module GMVCApp
  class CalculatorViewStandard < GMVC::View
    
    def initialize(*args)
      super
      @entry = self.attach_widget_to_attribute('entry', 'entry', :text=)
      @entry.editable = false
    end
    def about_to_close
      false
    end
  end
end