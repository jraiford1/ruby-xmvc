module GMVCApp
  class CalculatorViewScientific < GMVC::View
    def initialize(*args)
      super
      @entry = @builder.get_object("entry1")
      @entry.editable = false
      @model.set_attribute_reaction("entry", @entry) { |value| @entry.text = value }
    end
  end
end