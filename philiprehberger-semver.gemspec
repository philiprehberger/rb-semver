# frozen_string_literal: true

require_relative 'lib/philiprehberger/semver/gem_version'

Gem::Specification.new do |spec|
  spec.name = 'philiprehberger-semver'
  spec.version = Philiprehberger::Semver::VERSION
  spec.authors = ['Philip Rehberger']
  spec.email = ['me@philiprehberger.com']

  spec.summary = 'SemVer 2.0.0 parsing, comparison, range matching, and bump operations'
  spec.description = 'A lightweight Ruby library for parsing, comparing, sorting, ' \
                     'and matching semantic versions per the SemVer 2.0.0 specification.'
  spec.homepage = 'https://philiprehberger.com/open-source-packages/ruby/philiprehberger-semver'
  spec.license = 'MIT'
  spec.required_ruby_version = '>= 3.1.0'

  spec.metadata = {
    'homepage_uri' => spec.homepage,
    'source_code_uri' => 'https://github.com/philiprehberger/rb-semver',
    'changelog_uri' => 'https://github.com/philiprehberger/rb-semver/blob/main/CHANGELOG.md',
    'bug_tracker_uri' => 'https://github.com/philiprehberger/rb-semver/issues',
    'rubygems_mfa_required' => 'true'
  }

  spec.files = Dir['lib/**/*.rb', 'LICENSE', 'README.md', 'CHANGELOG.md']
  spec.require_paths = ['lib']
end
