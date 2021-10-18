$LOAD_PATH.unshift(File.expand_path('..', __FILE__))

begin
  require 'bundler/setup'
  Bundler.require(:default)
rescue
  # this runs when packaged as a gem (no bundler)
  require 'glimmer-dsl-libui'
  require 'befunge98'
  require 'array_include_methods'
  # add more gems if needed
end
require 'befunge98_gui_glimmer_dsl_libui/view/app_view'

class Befunge98GuiGlimmerDslLibui
  APP_ROOT = File.expand_path('../..', __FILE__)
  VERSION = File.read(File.join(APP_ROOT, 'VERSION'))
  LICENSE = File.read(File.join(APP_ROOT, 'LICENSE.txt'))
end
