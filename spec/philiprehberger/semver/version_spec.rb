# frozen_string_literal: true

require 'philiprehberger/semver'

RSpec.describe Philiprehberger::Semver::Version do
  describe '#next_pre_release' do
    it 'promotes a stable version using the default label' do
      version = Philiprehberger::Semver.parse('1.2.3')
      expect(version.next_pre_release.to_s).to eq('1.2.3-alpha.1')
    end

    it 'promotes a stable version with a custom label' do
      version = Philiprehberger::Semver.parse('1.2.3')
      expect(version.next_pre_release(label: 'beta').to_s).to eq('1.2.3-beta.1')
    end

    it 'increments a numeric trailing token' do
      version = Philiprehberger::Semver.parse('1.0.0-alpha.1')
      expect(version.next_pre_release.to_s).to eq('1.0.0-alpha.2')
    end

    it 'increments a numeric trailing token on an rc identifier' do
      version = Philiprehberger::Semver.parse('1.0.0-rc.4')
      expect(version.next_pre_release.to_s).to eq('1.0.0-rc.5')
    end

    it 'appends .1 when no numeric tail exists' do
      version = Philiprehberger::Semver.parse('1.0.0-rc')
      expect(version.next_pre_release.to_s).to eq('1.0.0-rc.1')
    end

    it 'appends .1 when the trailing token is non-numeric' do
      version = Philiprehberger::Semver.parse('1.0.0-alpha.beta')
      expect(version.next_pre_release.to_s).to eq('1.0.0-alpha.beta.1')
    end

    it 'ignores the label keyword when already a pre-release' do
      version = Philiprehberger::Semver.parse('1.0.0-alpha.1')
      expect(version.next_pre_release(label: 'beta').to_s).to eq('1.0.0-alpha.2')
    end

    it 'preserves build metadata' do
      version = Philiprehberger::Semver.parse('1.0.0-alpha.1+build.123')
      expect(version.next_pre_release.to_s).to eq('1.0.0-alpha.2+build.123')
    end

    it 'does not mutate the original version' do
      version = Philiprehberger::Semver.parse('1.2.3')
      version.next_pre_release
      expect(version.to_s).to eq('1.2.3')
      expect(version.pre_release).to be_nil
    end
  end
end
