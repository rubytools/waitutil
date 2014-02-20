# -*- encoding: utf-8 -*-
GEM_NAME = 'waitutil'

require File.expand_path("../lib/#{GEM_NAME}/version", __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Mikhail Bautin']
  gem.email         = ['mbautin@gmail.com']
  gem.description   = 'Utilities for waiting for various conditions'
  gem.summary       = 'Utilities for waiting for various conditions'
  gem.homepage      = "http://github.com/rubytools/#{GEM_NAME}"

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n").map(&:strip)
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = GEM_NAME
  gem.require_paths = ['lib']
  gem.version       = WaitUtil::VERSION

  gem.add_development_dependency 'rake', '~> 10.1'
  gem.add_development_dependency 'rspec', '~> 2.14'
  gem.add_development_dependency 'rubygems-tasks', '~> 0.2'

  gem.add_development_dependency 'webrick'
end
