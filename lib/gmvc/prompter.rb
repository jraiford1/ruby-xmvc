require "gtk3"
require_relative "../xmvc/prompter.rb"

module GMVC
  class Prompter
    def self.display(message, title = nil)
      dialog = Gtk::MessageDialog.new(
        :type => Gtk::MessageType::INFO)
      if title.nil?
        dialog.text = message
      else
        dialog.text = title
        dialog.secondary_text = message
      end
      dialog.run
      dialog.hide
      dialog.show
      dialog.destroy
    end
  end
end
