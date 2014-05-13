$LOAD_PATH.push File.expand_path('../lib', __FILE__)
require 'simple_relevance/version'

Gem::Specification.new do |s|
  s.name = 'simple_relevance'
  s.version = SimpleRelevance::VERSION
  s.platform = Gem::Platform::RUBY
  s.authors = ['Declan Frye', 'Eli Albert']
  s.email = 'deckleberryfrye@gmail.com'
  s.summary = 'Ruby wrapper to SimpleRelevance API.'
  s.description = 'Ruby wrapper to SimpleRelevance API. Allows you to upload data and to pull down recommendations.'

  s.add_dependency 'activesupport'
  s.add_dependency 'httparty'
  # s.add_development_dependency 'rspec'  # What does this do, exactly?

  s.require_paths = ['lib']
  s.files = `git ls-files`.split($\)
end
