# Changelog

All notable changes to this gem will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.3.0] - 2026-04-17

### Added
- `Version#next_pre_release(label:)` iterates pre-release identifiers — promotes stable → pre-release, or bumps the trailing numeric token on an existing pre-release

## [0.2.0] - 2026-04-04

### Added
- `Version#pre_release?` predicate method
- `Version#stable?` predicate method (true when major >= 1 and no pre-release)
- `Version#to_a` returning [major, minor, patch] array
- GitHub issue template gem version field
- Feature request "Alternatives considered" field

## [0.1.9] - 2026-03-31

### Added
- Add GitHub issue templates, dependabot config, and PR template

## [0.1.8] - 2026-03-31

### Changed
- Standardize README badges, support section, and license format

## [0.1.7] - 2026-03-26

### Changed

- Add Sponsor badge and fix License link format in README

## [0.1.6] - 2026-03-24

### Changed
- Add Usage subsections to README for better feature discoverability

## [0.1.5] - 2026-03-24

### Fixed
- Fix README one-liner to remove trailing period and match gemspec summary

## [0.1.4] - 2026-03-24

### Fixed
- Standardize README code examples to use double-quote require statements
- Remove inline comments from Development section to match template

## [0.1.3] - 2026-03-22

### Changed
- Expand test coverage from 20 to 32 examples

## [0.1.3] - 2026-03-21

### Fixed
- Standardize Installation section in README

## [0.1.2] - 2026-03-16

### Changed
- Add License badge to README
- Add bug_tracker_uri to gemspec
- Add Requirements section to README

## [0.1.0] - 2026-03-15

### Added
- Initial release
- SemVer 2.0.0 parsing and comparison
- Range matching with npm-style constraints
- Version bump operations
- Immutable value objects with Comparable
