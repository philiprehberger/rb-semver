# frozen_string_literal: true

module Philiprehberger
  module Semver
    # Parses SemVer 2.0.0 strings into {Version} objects.
    module Parser
      PRE_RELEASE_PART = '(?:-(?<pre>[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))'
      BUILD_PART = '(?:\+(?<build>[0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))'
      CORE_PART = '(?<major>0|[1-9]\d*)\.(?<minor>0|[1-9]\d*)\.(?<patch>0|[1-9]\d*)'
      SEMVER_REGEX = /\A#{CORE_PART}#{PRE_RELEASE_PART}?#{BUILD_PART}?\z/

      IDENTIFIER_REGEX = /\A[0-9A-Za-z-]+\z/

      # Parse a SemVer 2.0.0 string into a {Version}.
      #
      # Validates each dot-separated pre-release and build-metadata identifier
      # per SemVer 2.0.0 (identifiers must be non-empty and match +[0-9A-Za-z-]+).
      #
      # @param string [String] the version string to parse
      # @return [Version] the parsed immutable version
      # @raise [Error] if the string is not a valid SemVer 2.0.0 version or
      #   contains a malformed pre-release / build-metadata identifier
      def self.parse(string)
        match = SEMVER_REGEX.match(string.to_s.strip)
        raise Error, "invalid semver: #{string}" unless match

        validate_identifiers(match[:pre], 'pre-release')
        validate_identifiers(match[:build], 'build-metadata')

        Version.new(
          match[:major],
          match[:minor],
          match[:patch],
          pre_release: match[:pre],
          build_metadata: match[:build]
        )
      end

      # Validate that every dot-separated identifier is non-empty and matches
      # the SemVer 2.0.0 identifier grammar.
      #
      # @param segment [String, nil] the full pre-release or build-metadata segment
      # @param kind [String] human label used in the error message
      # @return [void]
      # @raise [Error] if any identifier is empty or contains invalid characters
      def self.validate_identifiers(segment, kind)
        return if segment.nil?

        segment.split('.', -1).each do |id|
          raise Error, "Invalid #{kind} identifier: #{id.inspect}" unless IDENTIFIER_REGEX.match?(id)
        end
      end
      private_class_method :validate_identifiers
    end
  end
end
