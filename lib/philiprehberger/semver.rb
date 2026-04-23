# frozen_string_literal: true

require_relative 'semver/gem_version'
require_relative 'semver/version'
require_relative 'semver/parser'
require_relative 'semver/range'

module Philiprehberger
  # SemVer 2.0.0 parsing, comparison, range matching, and bump operations.
  module Semver
    # Raised when a SemVer string, constraint, or operation is invalid.
    class Error < StandardError; end

    # Parse a SemVer string into a {Version}.
    #
    # @param string [String] a SemVer 2.0.0 string (e.g. +"1.2.3-beta.1+build.123"+)
    # @return [Version] the parsed immutable version
    # @raise [Error] if the string is not a valid SemVer 2.0.0 version
    def self.parse(string)
      Parser.parse(string)
    end

    # Check whether a version satisfies a constraint string.
    #
    # @param version_str [String, Version] the version to test
    # @param constraint [String] one or more comma-separated constraints
    #   (e.g. +">= 1.0.0, < 2.0.0"+, +"~> 1.4"+, +"^ 1.0.0"+)
    # @return [Boolean] +true+ if every constraint is satisfied
    # @raise [Error] if +version_str+ or +constraint+ is invalid
    def self.satisfies?(version_str, constraint)
      Range.satisfies?(version_str, constraint)
    end

    # Sort an array of SemVer strings in ascending order.
    #
    # @param versions [Array<String>] version strings to sort
    # @return [Array<String>] sorted version strings
    # @raise [Error] if any string is not a valid SemVer version
    def self.sort(versions)
      versions.map { |v| parse(v) }.sort.map(&:to_s)
    end
  end
end
