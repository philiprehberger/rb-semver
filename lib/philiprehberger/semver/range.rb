# frozen_string_literal: true

module Philiprehberger
  module Semver
    # Evaluates version constraint strings against a {Version}.
    #
    # Supports comma-separated constraints using the operators +>=+, +<=+,
    # +>+, +<+, +=+, +~>+ (pessimistic) and +^+ (compatible). A bare version
    # string (no operator) is treated as exact match.
    module Range
      OPERATOR_PREFIX_REGEX = /\A\s*[!~=<>^]/
      CONSTRAINT_REGEX = /\A\s*(>=|<=|>|<|=|~>|\^)\s*(.+)\z/

      # Check whether +version+ satisfies every comma-separated +constraint+.
      #
      # @param version [String, Version] the version to test
      # @param constraint [String] one or more comma-separated constraints
      # @return [Boolean] +true+ if every part of +constraint+ is satisfied
      # @raise [Error] if +version+ is invalid or +constraint+ is malformed
      def self.satisfies?(version, constraint)
        ver = version.is_a?(Version) ? version : Parser.parse(version)
        raise Error, 'Constraint cannot be empty' if constraint.nil? || constraint.strip.empty?

        constraint.split(',').all? do |part|
          check_constraint(ver, part.strip)
        end
      end

      def self.check_constraint(version, constraint)
        operator, ver_str = split_constraint(constraint)
        ver_str = pad_version(ver_str)
        target = Parser.parse(ver_str)

        apply_operator(operator, version, target)
      end

      def self.pad_version(ver_str)
        parts = ver_str.split('.')
        parts << '0' while parts.length < 3
        parts.join('.')
      end
      private_class_method :pad_version
      private_class_method :check_constraint

      def self.split_constraint(constraint)
        match = constraint.match(CONSTRAINT_REGEX)
        return [match[1], match[2].strip] if match

        raise Error, "Invalid version constraint: #{constraint.inspect}" if constraint.match?(OPERATOR_PREFIX_REGEX)
        raise Error, "Invalid version constraint: #{constraint.inspect}" if constraint.strip.empty?

        ['=', constraint.strip]
      end
      private_class_method :split_constraint

      COMPARISON_OPS = { '>=' => :>=, '<=' => :<=, '>' => :>, '<' => :<, '=' => :== }.freeze

      def self.apply_operator(operator, version, target)
        return version.send(COMPARISON_OPS[operator], target) if COMPARISON_OPS.key?(operator)
        return pessimistic_check(version, target) if operator == '~>'

        compatible_check(version, target)
      end
      private_class_method :apply_operator

      def self.pessimistic_check(version, target)
        return false if version < target

        if target.patch.zero? && target.minor.positive?
          version.major == target.major && version.minor >= target.minor
        else
          version.major == target.major && version.minor == target.minor
        end
      end
      private_class_method :pessimistic_check

      def self.compatible_check(version, target)
        return false if version < target

        if target.major.zero?
          version.major == target.major && version.minor == target.minor
        else
          version.major == target.major
        end
      end
      private_class_method :compatible_check
    end
  end
end
