# frozen_string_literal: true

require_relative 'semver/gem_version'
require_relative 'semver/version'
require_relative 'semver/parser'
require_relative 'semver/range'

module Philiprehberger
  module Semver
    class Error < StandardError; end

    def self.parse(string)
      Parser.parse(string)
    end

    def self.satisfies?(version_str, constraint)
      Range.satisfies?(version_str, constraint)
    end

    def self.sort(versions)
      versions.map { |v| parse(v) }.sort.map(&:to_s)
    end
  end
end
