module GMVC
  class View < XMVC::View
    attr_reader :builder
    def initialize(*args)
      super
      @builder = @controller.builder
    end
  end
end