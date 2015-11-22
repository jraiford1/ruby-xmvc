module XMVC
  class TreeMap
    attr_reader :items
    def item_for_object(object)
    end
  end
  class TreeItem
    attr_accessor :tree_map, :object
    def parent_item
      @tree_map
    end
  end
end
