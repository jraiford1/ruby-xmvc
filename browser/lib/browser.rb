require_relative '../../lib/gmvc'
require_relative 'window/browser_window'

module XMVCApp
  class BrowserApp < GMVC::Application
    def main
      win1 = BrowserWindow.new
      win1.open('default')
      win1.show
      self.perform_window_events
    end
  end
end

XMVCApp::BrowserApp.new.run
