require 'rubygems'

Gem::Specification.new do |s|
  s.name = %q{oh_my_log}
  s.authors = ["Fabrizio Spadaro"]
  s.email = ["work.fabriziospadaro@gmail.com"]
  s.license = "Unlicense"
  s.version = "1.0.5"
  s.date = %q{2018-11-26}
  s.summary = %q{A powerful auditing logging system}
  s.files = `git ls-files`.split($\)
  s.required_ruby_version = '>= 2.0.0'
  s.require_paths = ["lib"]
  s.add_runtime_dependency("rails", ">= 4.0")
  s.add_runtime_dependency("rails-observers", "~> 0.1.5")
  s.add_development_dependency 'coveralls'
  s.add_development_dependency 'rubocop', '~> 0.59.2'
  s.add_development_dependency 'bundler'

end