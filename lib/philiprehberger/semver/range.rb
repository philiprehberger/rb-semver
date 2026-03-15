# frozen_string_literal: true

module Philiprehberger
  module Semver
    module Range
      def self.satisfies?(version, constraint)
        ver = version.is_a?(Version) ? version : Parser.parse(version)

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
        match = constraint.match(/\A\s*(>=|<=|>|<|=|~>|\^)\s*(.+)\z/)
        return ['=', constraint.strip] unless match

        [match[1], match[2].strip]
      end
      private_class_method :split_constraint

      COMPARISON_OPS = { '>=' => :>=, '<=' => :<=, '>' => :>, '<' => :<, '=' => :== }.freeze

      def self.apply_operator(operator, version, target)
        return version.send(COMPARISON_OPS[operator], target) if COMPARISON_OPS.key?(operator)
        return pessimistic_check(version, target) if operator == '~>'

        compatible_check(version, target)
      end
      private_class_method :apply_operator

      def self.pessimistic_check(version, target) # rubocop:disable Naming/PredicateMethod
        return false if version < target

        if target.patch.zero? && target.minor.positive?
          version.major == target.major && version.minor >= target.minor
        else
          version.major == target.major && version.minor == target.minor
        end
      end
      private_class_method :pessimistic_check

      def self.compatible_check(version, target) # rubocop:disable Naming/PredicateMethod
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
