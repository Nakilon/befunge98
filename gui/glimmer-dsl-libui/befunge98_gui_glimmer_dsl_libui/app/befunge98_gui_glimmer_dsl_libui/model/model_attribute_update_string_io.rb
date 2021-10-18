require 'glimmer'

class Befunge98GuiGlimmerDslLibui
  module View
    class ModelAttributeUpdateStringIO < ::StringIO
      def initialize(model, attribute)
        @model = model
        @attribute = attribute
      end
    
      def print(string)
        Thread.new do
          @model.send("#{@attribute}=", "#{@model.send(@attribute)}#{string}")
        end
        sleep(0.01) # yields to other threads
      end
    end
  end
end
