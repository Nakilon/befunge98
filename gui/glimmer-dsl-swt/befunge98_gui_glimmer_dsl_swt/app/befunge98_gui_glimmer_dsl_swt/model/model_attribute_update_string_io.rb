require 'glimmer'

class ModelAttributeUpdateStringIO < ::StringIO
  include Glimmer
  
  def initialize(model, attribute)
    @model = model
    @attribute = attribute
  end

  def print(string)
    async_exec { @model.send("#{@attribute}=", "#{@model.send(@attribute)}#{string}") }
  end
end
