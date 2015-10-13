require_relative '../../../lib/gmvc'
require_relative 'window/class_heirarchy_browser_window'

module XMVCApp
  class CHBApp < GMVC::Application
    def main
      win1 = ClassHeirarchyBrowserWindow.new
      win1.show
      self.perform_window_events
    end
  end
end

XMVCApp::CHBApp.new.run
