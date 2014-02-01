# philiprehberger-semver

[![Gem Version](https://badge.fury.io/rb/philiprehberger-semver.svg)](https://rubygems.org/gems/philiprehberger-semver)
[![CI](https://github.com/philiprehberger/rb-semver/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-semver/actions/workflows/ci.yml)

SemVer 2.0.0 parsing, comparison, range matching, and bump operations for Ruby.

## Installation

Add to your Gemfile:

```ruby
gem 'philiprehberger-semver'
```

Or install directly:

```bash
gem install philiprehberger-semver
```

## Usage

```ruby
require 'philiprehberger/semver'

# Parse a version string
version = Philiprehberger::Semver.parse('1.2.3-beta.1+build.123')
version.major        # => 1
version.minor        # => 2
version.patch        # => 3
version.pre_release  # => 'beta.1'
version.build_metadata # => 'build.123'

# Compare versions
Philiprehberger::Semver.parse('2.0.0') > Philiprehberger::Semver.parse('1.9.9')  # => true
Philiprehberger::Semver.parse('1.0.0-alpha') < Philiprehberger::Semver.parse('1.0.0')  # => true

# Sort versions
Philiprehberger::Semver.sort(['2.0.0', '1.0.0', '1.1.0'])  # => ['1.0.0', '1.1.0', '2.0.0']

# Bump versions
version = Philiprehberger::Semver.parse('1.2.3')
version.bump(:major).to_s  # => '2.0.0'
version.bump(:minor).to_s  # => '1.3.0'
version.bump(:patch).to_s  # => '1.2.4'

# Range matching
Philiprehberger::Semver.satisfies?('1.5.0', '>= 1.0.0, < 2.0.0')  # => true
Philiprehberger::Semver.satisfies?('1.5.0', '~> 1.4')              # => true
Philiprehberger::Semver.satisfies?('1.9.0', '^ 1.0.0')             # => true
```

## API

### `Philiprehberger::Semver`

| Method | Description |
|---|---|
| `.parse(string)` | Parse a SemVer string into a `Version` object |
| `.satisfies?(version_str, constraint)` | Check if a version satisfies a constraint string |
| `.sort(versions)` | Sort an array of version strings |

### `Philiprehberger::Semver::Version`

| Method | Description |
|---|---|
| `#major` | Major version number |
| `#minor` | Minor version number |
| `#patch` | Patch version number |
| `#pre_release` | Pre-release identifier or `nil` |
| `#build_metadata` | Build metadata or `nil` |
| `#bump(level)` | Return a new `Version` bumped at `:major`, `:minor`, or `:patch` |
| `#to_s` | Format as a SemVer string |
| `#<=>` | Compare two versions per SemVer 2.0.0 precedence rules |

### Supported Constraint Operators

| Operator | Example | Description |
|---|---|---|
| `>=` | `>= 1.0.0` | Greater than or equal |
| `<=` | `<= 2.0.0` | Less than or equal |
| `>` | `> 1.0.0` | Greater than |
| `<` | `< 2.0.0` | Less than |
| `=` | `= 1.0.0` | Exact match |
| `~>` | `~> 1.4` | Pessimistic (same major, minor >= target) |
| `^` | `^ 1.0.0` | Compatible (same major) |

## Development

```bash
bundle install
bundle exec rspec
```

## License

MIT License. See [LICENSE](LICENSE) for details.
