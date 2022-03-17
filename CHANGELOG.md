# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project
adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## Changed

- Update the `miss` library.

## [1.3.0] - 2022-03-16

## Changed

- Fix the encoding for Decimal, Date and DateTime structs.

## [1.2.1] - 2022-02-25

## Changed

- Bump Poison to v5.0.

## [1.2.0] - 2021-06-21

### Added

- Use `MetaLogger.Formatter` for formatting logs and masking sensitive fields.

## [1.1.0] - 2020-12-23

### Added

- Add `drop_nil_fields` options to filter `null` JSON attributes from the request
  body sent to the API endpoint.

## [1.0.0] - 2020-10-09

### Changed

- Returns tuple with `:ok` or `:error` and a JSON string to enable clients
  to handle validation errors.

## [0.2.2] - 2020-10-08

### Added

- Add version field to `Segment.Analytics.Track`, `Segment.Analytics.Identify`,
  `Segment.Analytics.Alias`, `Segment.Analytics.Page`, `Segment.Analytics.Screen`
  and `Segment.Analytics.Group`.

## [0.2.1] - 2020-09-28

### Removed

- Removes unused fields.

## [0.2.0] - 2020-09-23

### Added

- Allow endpoint and API key to be passed via options to the new public function
  `Segment.Analytics.call/2`.

## [v0.1.1] - 2016-10-13

### Added

- First release.

[unreleased]: https://github.com/FindHotel/analytics-elixir/compare/1.3.0...master
[1.3.0]: https://github.com/FindHotel/analytics-elixir/compare/1.2.1...1.3.0
[1.2.1]: https://github.com/FindHotel/analytics-elixir/compare/1.2.0...1.2.1
[1.2.0]: https://github.com/FindHotel/analytics-elixir/compare/1.1.0...1.2.0
[1.1.0]: https://github.com/FindHotel/analytics-elixir/compare/1.0.0...1.1.0
[1.0.0]: https://github.com/FindHotel/analytics-elixir/compare/0.2.2...1.0.0
[0.2.2]: https://github.com/FindHotel/analytics-elixir/compare/0.2.1...0.2.2
[0.2.1]: https://github.com/FindHotel/analytics-elixir/compare/0.2.0...0.2.1
[0.2.0]: https://github.com/FindHotel/analytics-elixir/compare/v0.1.1...0.2.0
[v0.1.1]: https://github.com/FindHotel/analytics-elixir/releases/tag/v0.1.1
