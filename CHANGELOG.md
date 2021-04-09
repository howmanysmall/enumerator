# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.1.0] - 2021-04-09
### Added
- **[BREAKING]** Added `Enumerator.cast` to the enumerator function list, replacing `castToEnumerator`.
- Added all the missing tests for the module.
- Added `EnumeratorItem.type` and `EnumeratorItem.rawType()`, which return the `Enumerator` they belong to.
- Added this CHANGELOG.

### Changed
- Minor formatting updates.

### Removed
- Removed `castToEnumerator`, please use `Enumerator.cast` instead.

## [1.1.0] - 2021-03-18
### Added
- Added `EnumeratorItem.name` and `EnumeratorItem.rawName()`, which simply return the string version of the EnumeratorItem.

## [1.0.0] - ????-??-??
### Added
- All the code.

[2.1.0]: https://github.com/howmanysmall/enumerator/compare/v1.1.0...v2.1.0
[1.1.0]: https://github.com/howmanysmall/enumerator/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/howmanysmall/enumerator/releases/tag/1.0.0