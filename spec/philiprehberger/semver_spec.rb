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
  end
end
