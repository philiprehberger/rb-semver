# frozen_string_literal: true

module Philiprehberger
  module Semver
    # Immutable SemVer 2.0.0 version value object.
    #
    # Includes +Comparable+, so standard Ruby comparison operators work per
    # SemVer 2.0.0 precedence rules.
    class Version
      include Comparable

      # @return [Integer] the major version number
      attr_reader :major

      # @return [Integer] the minor version number
      attr_reader :minor

      # @return [Integer] the patch version number
      attr_reader :patch

      # @return [String, nil] the pre-release identifier string, or +nil+
      attr_reader :pre_release

      # @return [String, nil] the build metadata string, or +nil+
      attr_reader :build_metadata

      # @param major [Integer, String] major version
      # @param minor [Integer, String] minor version
      # @param patch [Integer, String] patch version
      # @param pre_release [String, nil] pre-release identifier (without leading +-+)
      # @param build_metadata [String, nil] build metadata (without leading +++)
      def initialize(major, minor, patch, pre_release: nil, build_metadata: nil)
        @major = major.to_i
        @minor = minor.to_i
        @patch = patch.to_i
        @pre_release = pre_release
        @build_metadata = build_metadata
        freeze
      end

      # Compare two versions per SemVer 2.0.0 precedence rules.
      #
      # Build metadata is ignored. Pre-release versions sort lower than their
      # release counterpart; pre-release identifiers are compared token-by-token
      # (numerics numerically, alphas lexicographically).
      #
      # @param other [Version] the other version to compare against
      # @return [Integer, nil] -1, 0, 1, or +nil+ if +other+ is not a {Version}
      def <=>(other)
        return nil unless other.is_a?(Version)

        result = [major, minor, patch] <=> [other.major, other.minor, other.patch]
        return result unless result.zero?

        compare_pre_release(pre_release, other.pre_release)
      end

      # Return a new {Version} with the given level bumped.
      #
      # Lower segments are reset to zero, and any pre-release / build metadata
      # is dropped.
      #
      # @param level [Symbol] one of +:major+, +:minor+, or +:patch+
      # @return [Version] a new bumped version
      # @raise [Error] if +level+ is not a recognized symbol
      def bump(level)
        case level
        when :major then self.class.new(major + 1, 0, 0)
        when :minor then self.class.new(major, minor + 1, 0)
        when :patch then self.class.new(major, minor, patch + 1)
        else raise Error, "unknown bump level: #{level}"
        end
      end

      # Return a new {Version} with its pre-release identifier iterated.
      #
      # When +self+ is stable (no pre-release), the result is promoted to a
      # pre-release using the given +label+ with a numeric suffix of +1+
      # (e.g. +1.2.3+ with +label: 'alpha'+ becomes +1.2.3-alpha.1+).
      #
      # When +self+ is already a pre-release, the +label+ keyword is ignored
      # and the existing pre-release string is iterated:
      # - if the last dot-separated token is numeric, that token is
      #   incremented (+alpha.1+ -> +alpha.2+, +rc.4+ -> +rc.5+)
      # - otherwise +.1+ is appended (+rc+ -> +rc.1+,
      #   +alpha.beta+ -> +alpha.beta.1+)
      #
      # +build_metadata+ is preserved on the returned {Version}. +self+ is
      # not mutated.
      #
      # @param label [String] pre-release label to use when promoting a
      #   stable version. Ignored when +self+ is already a pre-release.
      # @return [Version] a new {Version} with the iterated pre-release
      def next_pre_release(label: 'alpha')
        new_pre_release =
          if pre_release.nil?
            "#{label}.1"
          else
            iterate_pre_release(pre_release)
          end

        self.class.new(major, minor, patch, pre_release: new_pre_release, build_metadata: build_metadata)
      end

      # Return the dot-separated pre-release identifiers as an array.
      #
      # Numeric identifiers remain strings (SemVer-compliant identifiers are
      # strings even when numeric). Returns an empty array when the version
      # has no pre-release segment.
      #
      # @return [Array<String>] the pre-release identifiers, or +[]+ if none
      def prerelease_identifiers
        return [] if @pre_release.nil?

        @pre_release.split('.')
      end

      # @return [Boolean] +true+ if the version has a pre-release segment
      def pre_release?
        !@pre_release.nil?
      end

      # @return [Boolean] +true+ if major >= 1 and there is no pre-release
      def stable?
        @pre_release.nil? && @major >= 1
      end

      # @return [Array<Integer>] +[major, minor, patch]+
      def to_a
        [@major, @minor, @patch]
      end

      # @return [String] the canonical SemVer string
      def to_s
        str = "#{major}.#{minor}.#{patch}"
        str = "#{str}-#{pre_release}" if pre_release
        str = "#{str}+#{build_metadata}" if build_metadata
        str
      end

      private

      def compare_pre_release(left, right)
        return 0 if left.nil? && right.nil?
        return 1 if left.nil?
        return -1 if right.nil?

        compare_pre_release_identifiers(left.split('.'), right.split('.'))
      end

      def compare_pre_release_identifiers(left_ids, right_ids)
        left_ids.zip(right_ids).each do |l, r|
          return 1 if r.nil?

          cmp = compare_identifier(l, r)
          return cmp unless cmp.zero?
        end
        left_ids.length <=> right_ids.length
      end

      def compare_identifier(left, right)
        l_num = integer?(left)
        r_num = integer?(right)

        return left.to_i <=> right.to_i if l_num && r_num
        return -1 if l_num
        return 1 if r_num

        left <=> right
      end

      def integer?(value)
        value.match?(/\A\d+\z/)
      end

      def iterate_pre_release(identifier)
        tokens = identifier.split('.')
        if integer?(tokens.last)
          tokens[-1] = (tokens.last.to_i + 1).to_s
          tokens.join('.')
        else
          "#{identifier}.1"
        end
      end
    end
  end
end
