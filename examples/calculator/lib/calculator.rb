require_relative '../../../lib/gmvc'
require_relative 'window/calculator_window'

module XMVCApp
  class CalculatorApp < GMVC::Application
    def main
      win1 = CalculatorWindow.new
      win1.open('standard')
      win1.show
      win2 = CalculatorWindow.new
      win2.open('scientific')
      win2.show
      win1["entry"] = '23.0'
      win2["entry1"] = '16.0'
      self.perform_window_events
    end
  end
end

XMVCApp::CalculatorApp.new.run