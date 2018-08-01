Gem::Specification.new do |spec|
  spec.name         = "befunge98"
  spec.version      = "0.0.0.1"
  spec.summary      = "[WIP] Probably the first Befunge-98 interpreter in Ruby."

  spec.author       = "Victor Maslov aka Nakilon"
  spec.email        = "nakilon@gmail.com"
  spec.license      = "MIT"
  spec.homepage     = "https://github.com/nakilon/befunge98"
  spec.metadata     = {"source_code_uri" => "https://github.com/nakilon/befunge98"}

  spec.add_development_dependency "minitest"

  spec.require_path = "lib"
  # spec.bindir       = "bin"
  # spec.executable   = "befunge98"
  spec.test_file    = "test.rb"
  spec.files        = `git ls-files -z`.split(?\0) - spec.test_files
end
