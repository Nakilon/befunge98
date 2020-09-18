Gem::Specification.new do |spec|
  spec.name         = "befunge98"
  spec.version      = "0.0.1"
  spec.summary      = "[WIP] Probably the first Befunge-98 interpreter in Ruby"

  spec.author       = "Victor Maslov aka Nakilon"
  spec.email        = "nakilon@gmail.com"
  spec.license      = "MIT"
  spec.metadata     = {"source_code_uri" => "https://github.com/nakilon/befunge98"}

  spec.require_path = "lib"
  spec.add_development_dependency "minitest"

  # spec.bindir       = "bin"
  # spec.executable   = "befunge98"
  spec.test_file    = "test.rb"
  spec.files        = %w{ LICENSE befunge98.gemspec lib/befunge98.rb bin/befunge98 }
end
