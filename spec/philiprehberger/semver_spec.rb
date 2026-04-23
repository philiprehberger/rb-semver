# frozen_string_literal: true

require 'philiprehberger/semver'

RSpec.describe Philiprehberger::Semver do
  describe 'VERSION' do
    it 'has a version number' do
      expect(Philiprehberger::Semver::VERSION).not_to be_nil
    end
  end

  describe '.parse' do
    it 'parses simple version' do
      v = described_class.parse('1.2.3')
      expect(v.major).to eq(1)
      expect(v.minor).to eq(2)
      expect(v.patch).to eq(3)
    end

    it 'parses version with pre_release' do
      v = described_class.parse('1.0.0-alpha')
      expect(v.pre_release).to eq('alpha')
    end

    it 'parses version with build metadata' do
      v = described_class.parse('1.0.0+build.1')
      expect(v.build_metadata).to eq('build.1')
    end

    it 'parses full version string' do
      v = described_class.parse('1.0.0-beta.1+build.123')
      expect(v.major).to eq(1)
      expect(v.pre_release).to eq('beta.1')
      expect(v.build_metadata).to eq('build.123')
    end

    it 'raises on invalid input' do
      expect { described_class.parse('not.a.version!') }
        .to raise_error(Philiprehberger::Semver::Error)
    end
  end

  describe 'comparison' do
    it 'compares major versions' do
      expect(described_class.parse('2.0.0')).to be > described_class.parse('1.9.9')
    end

    it 'ranks pre-release lower than release' do
      expect(described_class.parse('1.0.0-alpha')).to be < described_class.parse('1.0.0')
    end

    it 'compares pre-release identifiers' do
      expect(described_class.parse('1.0.0-alpha')).to be < described_class.parse('1.0.0-beta')
    end

    it 'compares numeric pre-release identifiers numerically' do
      expect(described_class.parse('1.0.0-1')).to be < described_class.parse('1.0.0-2')
    end
  end

  describe '.sort' do
    it 'sorts version strings' do
      input = ['2.0.0', '1.0.0', '1.1.0', '1.0.0-alpha']
      expected = ['1.0.0-alpha', '1.0.0', '1.1.0', '2.0.0']
      expect(described_class.sort(input)).to eq(expected)
    end
  end

  describe Philiprehberger::Semver::Version do
    describe '#bump' do
      let(:version) { Philiprehberger::Semver.parse('1.2.3') }

      it 'bumps major' do
        expect(version.bump(:major).to_s).to eq('2.0.0')
      end

      it 'bumps minor' do
        expect(version.bump(:minor).to_s).to eq('1.3.0')
      end

      it 'bumps patch' do
        expect(version.bump(:patch).to_s).to eq('1.2.4')
      end
    end

    describe '#pre_release?' do
      it 'returns true for pre-release versions' do
        version = Philiprehberger::Semver.parse('1.0.0-alpha')
        expect(version.pre_release?).to be true
      end

      it 'returns false for release versions' do
        version = Philiprehberger::Semver.parse('1.0.0')
        expect(version.pre_release?).to be false
      end

      it 'returns true for beta versions' do
        version = Philiprehberger::Semver.parse('2.0.0-beta.1')
        expect(version.pre_release?).to be true
      end
    end

    describe '#stable?' do
      it 'returns true for stable releases' do
        version = Philiprehberger::Semver.parse('1.0.0')
        expect(version.stable?).to be true
      end

      it 'returns false for pre-release versions' do
        version = Philiprehberger::Semver.parse('1.0.0-rc.1')
        expect(version.stable?).to be false
      end

      it 'returns false for 0.x versions' do
        version = Philiprehberger::Semver.parse('0.9.0')
        expect(version.stable?).to be false
      end

      it 'returns true for high major versions' do
        version = Philiprehberger::Semver.parse('5.2.1')
        expect(version.stable?).to be true
      end
    end

    describe '#to_a' do
      it 'returns array of major, minor, patch' do
        version = Philiprehberger::Semver.parse('1.2.3')
        expect(version.to_a).to eq([1, 2, 3])
      end

      it 'ignores pre-release and build metadata' do
        version = Philiprehberger::Semver.parse('1.2.3-alpha+build')
        expect(version.to_a).to eq([1, 2, 3])
      end
    end

    describe '#to_s' do
      it 'formats full version' do
        v = Philiprehberger::Semver.parse('1.0.0-beta.1+build.123')
        expect(v.to_s).to eq('1.0.0-beta.1+build.123')
      end
    end
  end

  describe '.satisfies?' do
    it 'matches >= constraint' do
      expect(described_class.satisfies?('1.5.0', '>= 1.0.0')).to be true
      expect(described_class.satisfies?('0.9.0', '>= 1.0.0')).to be false
    end

    it 'matches < constraint' do
      expect(described_class.satisfies?('1.0.0', '< 2.0.0')).to be true
      expect(described_class.satisfies?('2.0.0', '< 2.0.0')).to be false
    end

    it 'matches combined constraints' do
      expect(described_class.satisfies?('1.5.0', '>= 1.0.0, < 2.0.0')).to be true
      expect(described_class.satisfies?('2.0.0', '>= 1.0.0, < 2.0.0')).to be false
    end

    it 'matches ~> pessimistic constraint' do
      expect(described_class.satisfies?('1.5.0', '~> 1.4')).to be true
      expect(described_class.satisfies?('2.0.0', '~> 1.4')).to be false
    end

    it 'matches ^ compatible constraint' do
      expect(described_class.satisfies?('1.9.0', '^ 1.0.0')).to be true
      expect(described_class.satisfies?('2.0.0', '^ 1.0.0')).to be false
    end

    it 'matches exact version constraint' do
      expect(described_class.satisfies?('1.2.3', '1.2.3')).to be true
      expect(described_class.satisfies?('1.2.4', '1.2.3')).to be false
    end

    it 'matches <= constraint' do
      expect(described_class.satisfies?('1.0.0', '<= 1.0.0')).to be true
      expect(described_class.satisfies?('1.0.1', '<= 1.0.0')).to be false
    end

    it 'matches > constraint' do
      expect(described_class.satisfies?('1.0.1', '> 1.0.0')).to be true
      expect(described_class.satisfies?('1.0.0', '> 1.0.0')).to be false
    end
  end

  describe 'pre-release comparison ordering' do
    it 'orders alpha < beta < rc' do
      alpha = described_class.parse('1.0.0-alpha')
      beta = described_class.parse('1.0.0-beta')
      rc = described_class.parse('1.0.0-rc')
      expect(alpha).to be < beta
      expect(beta).to be < rc
    end

    it 'orders numeric pre-release identifiers by value' do
      expect(described_class.parse('1.0.0-1')).to be < described_class.parse('1.0.0-10')
    end

    it 'ranks numeric identifiers lower than string identifiers' do
      expect(described_class.parse('1.0.0-1')).to be < described_class.parse('1.0.0-alpha')
    end

    it 'compares multi-segment pre-release identifiers' do
      expect(described_class.parse('1.0.0-alpha.1')).to be < described_class.parse('1.0.0-alpha.2')
    end

    it 'ranks shorter pre-release lower when prefix matches' do
      expect(described_class.parse('1.0.0-alpha')).to be < described_class.parse('1.0.0-alpha.1')
    end
  end

  describe 'build metadata in comparison' do
    it 'ignores build metadata when comparing equal versions' do
      a = described_class.parse('1.0.0+build.1')
      b = described_class.parse('1.0.0+build.999')
      expect(a == b).to be true
    end

    it 'ignores build metadata when sorting' do
      a = described_class.parse('1.0.0+aaa')
      b = described_class.parse('1.0.0+zzz')
      expect(a <=> b).to eq(0)
    end
  end

  describe 'parse invalid strings' do
    it 'raises on leading zeros in major' do
      expect { described_class.parse('01.0.0') }.to raise_error(Philiprehberger::Semver::Error)
    end

    it 'raises on missing patch' do
      expect { described_class.parse('1.0') }.to raise_error(Philiprehberger::Semver::Error)
    end

    it 'raises on empty string' do
      expect { described_class.parse('') }.to raise_error(Philiprehberger::Semver::Error)
    end

    it 'raises on nil input' do
      expect { described_class.parse(nil) }.to raise_error(Philiprehberger::Semver::Error)
    end
  end

  describe 'to_s roundtrip' do
    it 'roundtrips a simple version' do
      expect(described_class.parse('1.2.3').to_s).to eq('1.2.3')
    end

    it 'roundtrips a version with pre-release' do
      expect(described_class.parse('1.0.0-alpha.1').to_s).to eq('1.0.0-alpha.1')
    end

    it 'roundtrips a version with build metadata' do
      expect(described_class.parse('1.0.0+build.42').to_s).to eq('1.0.0+build.42')
    end

    it 'roundtrips a full version' do
      input = '1.0.0-rc.1+build.123'
      expect(described_class.parse(input).to_s).to eq(input)
    end
  end

  describe 'bump from pre-release' do
    it 'drops pre-release on patch bump' do
      v = described_class.parse('1.0.0-alpha')
      expect(v.bump(:patch).to_s).to eq('1.0.1')
    end

    it 'drops pre-release on minor bump' do
      v = described_class.parse('1.0.0-alpha')
      expect(v.bump(:minor).to_s).to eq('1.1.0')
    end

    it 'drops pre-release on major bump' do
      v = described_class.parse('1.0.0-alpha')
      expect(v.bump(:major).to_s).to eq('2.0.0')
    end

    it 'raises on unknown bump level' do
      v = described_class.parse('1.0.0')
      expect { v.bump(:unknown) }.to raise_error(Philiprehberger::Semver::Error)
    end
  end

  describe 'sort stability' do
    it 'sorts a complex list correctly' do
      input = ['3.0.0', '1.0.0-alpha', '1.0.0-beta', '1.0.0', '2.1.0', '2.0.0']
      expected = ['1.0.0-alpha', '1.0.0-beta', '1.0.0', '2.0.0', '2.1.0', '3.0.0']
      expect(described_class.sort(input)).to eq(expected)
    end

    it 'sorts pre-release versions with numeric identifiers' do
      input = ['1.0.0-rc.2', '1.0.0-rc.1', '1.0.0-rc.10']
      expected = ['1.0.0-rc.1', '1.0.0-rc.2', '1.0.0-rc.10']
      expect(described_class.sort(input)).to eq(expected)
    end
  end

  describe '#prerelease_identifiers' do
    it 'returns dot-separated identifiers as an array of strings' do
      v = described_class.parse('1.2.3-beta.1')
      expect(v.prerelease_identifiers).to eq(%w[beta 1])
    end

    it 'returns an empty array when the version has no pre-release' do
      v = described_class.parse('1.2.3')
      expect(v.prerelease_identifiers).to eq([])
    end

    it 'keeps numeric identifiers as strings' do
      v = described_class.parse('1.0.0-0.3.7')
      expect(v.prerelease_identifiers).to eq(%w[0 3 7])
      expect(v.prerelease_identifiers).to all(be_a(String))
    end

    it 'handles a single identifier' do
      v = described_class.parse('1.0.0-alpha')
      expect(v.prerelease_identifiers).to eq(['alpha'])
    end

    it 'ignores build metadata' do
      v = described_class.parse('1.0.0-rc.1+build.42')
      expect(v.prerelease_identifiers).to eq(%w[rc 1])
    end

    it 'returns an empty array when only build metadata is present' do
      v = described_class.parse('1.0.0+build.42')
      expect(v.prerelease_identifiers).to eq([])
    end
  end

  describe 'parser identifier validation' do
    it 'accepts valid alphanumeric pre-release identifiers' do
      expect { described_class.parse('1.0.0-alpha-1.beta2') }.not_to raise_error
    end

    it 'accepts hyphens inside pre-release identifiers' do
      expect { described_class.parse('1.0.0-x-y-z') }.not_to raise_error
    end

    it 'accepts valid build-metadata identifiers' do
      expect { described_class.parse('1.0.0+build-42.sha-abc') }.not_to raise_error
    end

    it 'rejects an underscore in pre-release (caught by regex)' do
      expect { described_class.parse('1.0.0-alpha_1') }.to raise_error(Philiprehberger::Semver::Error)
    end

    it 'rejects a space in build metadata' do
      expect { described_class.parse('1.0.0+build 42') }.to raise_error(Philiprehberger::Semver::Error)
    end
  end

  describe '.satisfies? invalid constraints' do
    it 'raises on an unrecognized operator-looking prefix' do
      expect { described_class.satisfies?('1.0.0', '~1.0.0') }
        .to raise_error(Philiprehberger::Semver::Error, /Invalid version constraint/)
    end

    it 'raises on a not-equal operator' do
      expect { described_class.satisfies?('1.0.0', '!= 1.0.0') }
        .to raise_error(Philiprehberger::Semver::Error, /Invalid version constraint/)
    end

    it 'still accepts a plain version as exact match' do
      expect(described_class.satisfies?('1.2.3', '1.2.3')).to be true
    end

    it 'raises on an empty constraint part' do
      expect { described_class.satisfies?('1.0.0', '') }
        .to raise_error(Philiprehberger::Semver::Error)
    end
  end
end
