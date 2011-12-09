module GMVCApp
  class CalculatorViewScientific < GMVC::View
    def initialize(*args)
      super
      @entry = self.attach_widget_to_attribute('entry1', 'entry', :text=)
      @entry.editable = false
    end
  end
end