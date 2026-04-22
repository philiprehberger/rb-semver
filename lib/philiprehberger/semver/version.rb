# frozen_string_literal: true

module Philiprehberger
  module Semver
    class Version
      include Comparable

      attr_reader :major, :minor, :patch, :pre_release, :build_metadata

      def initialize(major, minor, patch, pre_release: nil, build_metadata: nil)
        @major = major.to_i
        @minor = minor.to_i
        @patch = patch.to_i
        @pre_release = pre_release
        @build_metadata = build_metadata
        freeze
      end

      def <=>(other)
        return nil unless other.is_a?(Version)

        result = [major, minor, patch] <=> [other.major, other.minor, other.patch]
        return result unless result.zero?

        compare_pre_release(pre_release, other.pre_release)
      end

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

      def pre_release?
        !@pre_release.nil?
      end

      def stable?
        @pre_release.nil? && @major >= 1
      end

      def to_a
        [@major, @minor, @patch]
      end

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
