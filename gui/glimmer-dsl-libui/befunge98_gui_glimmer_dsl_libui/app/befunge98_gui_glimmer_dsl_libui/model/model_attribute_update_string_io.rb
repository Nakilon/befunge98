require 'glimmer'

class Befunge98GuiGlimmerDslLibui
  module View
    class ModelAttributeUpdateStringIO < ::StringIO
      def initialize(model, attribute)
        @model = model
        @attribute = attribute
      end
    
      def print(string)
        Glimmer::LibUI.queue_main { @model.send("#{@attribute}=", "#{@model.send(@attribute)}#{string}") }
      end
    end
  end
end
