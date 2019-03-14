# -*- encoding: utf-8 -*-
# frozen_string_literal: true
require 'rubygems'
$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'oh_my_log/version'

Gem::Specification.new do |s|
  s.name = %q{oh_my_log}
  s.authors = ["Fabrizio Spadaro"]
  s.email = ["work.fabriziospadaro@gmail.com"]
  s.license = "MIT"
  s.version = OhMyLog::VERSION
  s.platform = Gem::Platform::RUBY
  s.date = %q{2018-11-26}
  s.homepage = 'https://github.com/fabriziospadaro/oh_my_log'
  s.summary = %q{A powerful auditing logging system}
  s.files = `git ls-files`.split($\)
  s.required_ruby_version = '>= 2.3.0' #, '<= 2.5.0'
  s.require_paths = ["lib"]

  if RUBY_VERSION >= '2.4'
    s.add_runtime_dependency 'rails', '>= 4.2.0', '< 7.0'
  else
    s.add_runtime_dependency 'railties', '>= 4.2.0', '< 6.0'
  end
  s.add_runtime_dependency 'json', '~> 0'
  s.add_runtime_dependency("rails-observers", "~> 0.1.5")
  s.add_development_dependency 'coveralls', '~> 0'
  s.add_development_dependency 'rubocop', '~> 0.59.2'
  s.add_development_dependency 'bundler', '~> 0'
  s.add_development_dependency 'appraisal', '~> 0'
  s.add_development_dependency 'sqlite3', '1.3.10'
  s.add_development_dependency 'rspec-core', '~> 0'
  s.add_development_dependency 'wwtd', '~> 0'
  s.add_development_dependency 'rspec-rails', '~> 0'
end