# frozen_string_literal: true

require_relative "lib/open_project/persian_font/version"

Gem::Specification.new do |spec|
  spec.name          = "openproject-persian-font"
  spec.version       = OpenProject::PersianFont::VERSION
  spec.authors       = ["Sepehr Safaeian"]
  spec.email         = ["44450634+sepehr-safaeian@users.noreply.github.com"]

  spec.summary       = "Persian typography extension for OpenProject using Vazirmatn"
  spec.description   = "A lightweight OpenProject extension that brings Persian typography to OpenProject using the Vazirmatn typeface, with locally hosted font assets and seamless integration."
  spec.homepage      = "https://github.com/Sepehr-Safaeian/openproject-persian-font"
  spec.license       = "MIT"

  spec.files         = Dir["{app,config,lib}/**/*", "LICENSE", "FONT-LICENSE.txt", "README.md", "CHANGELOG.md"]
  spec.require_paths = ["lib"]

  spec.required_ruby_version = ">= 3.1.0"

  spec.add_development_dependency "bundler", ">= 2.0"
  spec.add_development_dependency "rake", ">= 13.0"
  spec.add_development_dependency "rspec", "~> 3.13"
  spec.add_development_dependency "rubocop", "~> 1.60"
  spec.add_development_dependency "webmock", "~> 3.23"
end
