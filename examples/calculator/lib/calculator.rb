require_relative '../../../lib/gmvc'
require_relative 'window/calculator_window'

module XMVCApp
  class CalculatorApp < GMVC::Application
    def main
      puts "Project Directory: #{$project_directory}"
      win = CalculatorWindow.new
      win.show
      self.perform_window_events
    end
  end
end

XMVCApp::CalculatorApp.new.run