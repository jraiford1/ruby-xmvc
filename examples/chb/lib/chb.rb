#!/usr/bin/env ruby
require 'singleton'
require 'set'
require 'gtk2'
require_relative 'code_info'
require_relative '../../../lib/gmvc'
require_relative 'window/class_heirarchy_browser_window'

module XMVCApp
  class CHBApp < GMVC::Application
    include Singleton
    def main
      win1 = ClassHeirarchyBrowserWindow.new
      puts self.class_info_hash.keys.size
      puts self.method_infos.keys.size
      win1.show
      self.perform_window_events
    end
    def class_info_hash
      if !@class_info_hash.nil?
        return @class_info_hash
      end
      @class_info_hash = ClassInfoHash.new
    end
    def method_infos
      if !@method_infos.nil?
        return @method_infos
      end
      @method_infos = Hash.new {|hash,key| hash[key] = []}
      self.class_info_hash.each do |class_name, class_info|
        class_info.inst_methods.each do |method_name, method_info|
          @method_infos[method_name] << method_info
        end
        class_info.cls_methods.each do |method_name, method_info|
          @method_infos[method_name] << method_info
        end
      end
      @method_infos.default = nil
      @method_infos
    end
  end
end

XMVCApp::CHBApp.instance.run