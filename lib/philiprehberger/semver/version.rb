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
    end
  end
end
