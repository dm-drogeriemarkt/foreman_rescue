require File.expand_path('../lib/foreman_rescue/version', __FILE__)

Gem::Specification.new do |s|
  s.name        = 'foreman_rescue'
  s.version     = ForemanRescue::VERSION
  s.license     = 'GPL-3.0'
  s.authors     = ['Timo Goebel']
  s.email       = ['timo.goebel@dm.de']
  s.homepage    = 'https://github.com/dm-drogeriemarkt/foreman_rescue'
  s.summary     = 'Provides the ability to boot a host into a rescue system.'
  # also update locale/gemspec.rb
  s.description = 'Foreman Plugin to provide the ability to boot a host into a rescue system.'

  s.files = Dir['{app,config,db,lib,locale}/**/*'] + ['LICENSE', 'Rakefile', 'README.md']
  s.test_files = Dir['test/**/*']

  s.add_development_dependency 'rubocop', '0.49.1'
  s.add_development_dependency 'rdoc'
end
