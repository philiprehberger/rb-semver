# philiprehberger-semver

[![Tests](https://github.com/philiprehberger/rb-semver/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/rb-semver/actions/workflows/ci.yml)
[![Gem Version](https://badge.fury.io/rb/philiprehberger-semver.svg)](https://rubygems.org/gems/philiprehberger-semver)
[![Last updated](https://img.shields.io/github/last-commit/philiprehberger/rb-semver)](https://github.com/philiprehberger/rb-semver/commits/main)

SemVer 2.0.0 parsing, comparison, range matching, and bump operations

## Requirements

- Ruby >= 3.1

## Installation

Add to your Gemfile:

```ruby
gem "philiprehberger-semver"
```

Or install directly:

```bash
gem install philiprehberger-semver
```

## Usage

```ruby
require "philiprehberger/semver"

# Parse a version string
version = Philiprehberger::Semver.parse('1.2.3-beta.1+build.123')
version.major          # => 1
version.minor          # => 2
version.patch          # => 3
version.pre_release    # => 'beta.1'
version.build_metadata # => 'build.123'
version.to_s           # => '1.2.3-beta.1+build.123'
```

### Comparison

Versions implement `Comparable`, so all standard Ruby comparison operators work. Pre-release versions sort lower than their release counterpart, and pre-release identifiers are compared per SemVer 2.0.0 precedence rules.

```ruby
Philiprehberger::Semver.parse('2.0.0') > Philiprehberger::Semver.parse('1.9.9')   # => true
Philiprehberger::Semver.parse('1.0.0-alpha') < Philiprehberger::Semver.parse('1.0.0')  # => true
Philiprehberger::Semver.parse('1.0.0-alpha') < Philiprehberger::Semver.parse('1.0.0-beta')  # => true
Philiprehberger::Semver.parse('1.0.0-alpha.1') < Philiprehberger::Semver.parse('1.0.0-alpha.2')  # => true
```

### Sorting

Pass an array of version strings and get back a sorted array in ascending order.

```ruby
Philiprehberger::Semver.sort(['2.0.0', '1.0.0', '1.1.0'])
# => ['1.0.0', '1.1.0', '2.0.0']

Philiprehberger::Semver.sort(['1.0.0', '1.0.0-alpha', '1.0.0-beta'])
# => ['1.0.0-alpha', '1.0.0-beta', '1.0.0']
```

### Bumping

`bump` returns a new immutable `Version` with the specified level incremented. Minor and patch are reset to zero when a higher level is bumped.

```ruby
version = Philiprehberger::Semver.parse('1.2.3')
version.bump(:major).to_s  # => '2.0.0'
version.bump(:minor).to_s  # => '1.3.0'
version.bump(:patch).to_s  # => '1.2.4'
```

### Version Predicates

```ruby
require "philiprehberger/semver"

version = Philiprehberger::Semver.parse("1.0.0-alpha")
version.pre_release?  # => true
version.stable?       # => false

stable = Philiprehberger::Semver.parse("2.1.0")
stable.stable?        # => true
stable.to_a           # => [2, 1, 0]
```

### Range Matching

Check whether a version satisfies one or more comma-separated constraints. Supports standard comparison operators, pessimistic (`~>`), and caret (`^`) constraints.

```ruby
Philiprehberger::Semver.satisfies?('1.5.0', '>= 1.0.0, < 2.0.0')  # => true
Philiprehberger::Semver.satisfies?('1.5.0', '~> 1.4')              # => true
Philiprehberger::Semver.satisfies?('1.9.0', '^ 1.0.0')             # => true
Philiprehberger::Semver.satisfies?('2.0.0', '>= 1.0.0, < 2.0.0')  # => false
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
| `#pre_release?` | `true` if the version has a pre-release segment |
| `#stable?` | `true` if major >= 1 and no pre-release |
| `#to_a` | Return `[major, minor, patch]` as an array |
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
bundle exec rubocop
```

## Support

If you find this project useful:

⭐ [Star the repo](https://github.com/philiprehberger/rb-semver)

🐛 [Report issues](https://github.com/philiprehberger/rb-semver/issues?q=is%3Aissue+is%3Aopen+label%3Abug)

💡 [Suggest features](https://github.com/philiprehberger/rb-semver/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement)

❤️ [Sponsor development](https://github.com/sponsors/philiprehberger)

🌐 [All Open Source Projects](https://philiprehberger.com/open-source-packages)

💻 [GitHub Profile](https://github.com/philiprehberger)

🔗 [LinkedIn Profile](https://www.linkedin.com/in/philiprehberger)

## License

[MIT](LICENSE)
