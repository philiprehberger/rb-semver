# frozen_string_literal: true

module Philiprehberger
  module Semver
    module Parser
      PRE_RELEASE_PART = '(?:-(?<pre>[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))'
      BUILD_PART = '(?:\+(?<build>[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))'
      CORE_PART = '(?<major>0|[1-9]\d*)\.(?<minor>0|[1-9]\d*)\.(?<patch>0|[1-9]\d*)'
      SEMVER_REGEX = /\A#{CORE_PART}#{PRE_RELEASE_PART}?#{BUILD_PART}?\z/

      def self.parse(string)
        match = SEMVER_REGEX.match(string.to_s.strip)
        raise Error, "invalid semver: #{string}" unless match

        Version.new(
          match[:major],
          match[:minor],
          match[:patch],
          pre_release: match[:pre],
          build_metadata: match[:build]
        )
      end
    end
  end
end
