# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.4.0] - 2018-02-16
### Fixed
- Cache improvements

## [0.3.6] - 2018-02-14
### Added
- Travis
- `Console` Rake task

## [0.3.5] - 2018-02-14
### Added
- `Esi::Response` caching
- `SolarSystem`, `Star`, `Planet`, `Moon`, `Stargate`, `Station`, `Structure`,
  `DogmaAttributes`, and `DogmaEffects` calls
- `Esi::Client.method?` and `Esi::Client.plural_method?` methods

### Fixed
- Documentation for `expires_at` on `Esi::Client`

## [0.2.34] - 2018-01-31
### Added
- `CoprorationWallet` call

### Fixed
- Logging improvements

## [0.2.24] - 2018-01-05
### Changed
- `Esi::Client::MAX_ATTEMPTS` is now 2 instead of 3

### Fixed
- Logging improvements

## [0.2.23] - 2017-12-11
### Added
- `ApiRefreshTokenExpiredError` class

### Fixed
- Logging improvements

## [0.2.12] - 2017-12-09
### Fixed
- Logging improvements

## [0.2.11] - 2017-12-09
### Added
- Error logging

## [0.2.10] - 2017-12-09
### Added
- `CharacterSkills` call

## [0.2.9] - 2017-11-15
### Added
- you can now provide a custom callback url to omniauth strategies

## [0.2.8] - 2017-11-12
### Changed
- `Esi::Client.request` will now also rescue `Faraday::ConnectionFailed`

## [0.2.7] - 2017-11-05
### Added
- `Esi::Response` logging

## [0.2.5] - 2017-11-04
### Fixed
- Made `Esi::Response` more consistent

## [0.2.4] - 2017-11-04
### Changed
- Default timeout to 60
- Set Asset calls as `paginated`

## [0.2.3] - 2017-11-04
### Changed
- `Esi::Client.request` will now also rescue `Faraday::SSLError`

## [0.2.2] - 2017-11-04
### Changed
- Message output in `ApiRequestError`
- `Esi::Client::MAX_ATTEMPTS` is now 3 instead of 5

## [0.2.1]
### Fixed
- incorrect parameter use in `CorporationAssets` call

## [0.2.0] - 2017-10-29
### Added
- `CharacterAssets` and `CorporationAssets` calls

## [0.1.17] - 2017-10-29
### Added
- `MarketTypes` call

## [0.1.16] - 2017-10-27
### Added
- `Regions`, `Region`, `Constellations`, and `Constellation` calls

### Fixed
- Small fix to `MarketHistory` and `MarketOrders` call `params`

## [0.1.15] - 2017-10-25
### Added
- `IndustryFacilities`, and `IndustrySystems` calls

## [0.1.14] - 2017-10-22
### Adedd
- bin/build.sh

### Fixed
- fixed an issue with completed industry jobs in the `CharacterInsdustryJobs` call
- `CharacterBlueprints`, and `CorporationBlueprints` calls

## [0.1.11] - 2017-10-22
### Added
- `Esi::Calls#list` method

## [0.1.10] - 2017-10-22
### Added
- `Esi::Calls::Info` class

## [0.1.9] - 2017-10-21
### Added
- `CorporateIndustryJobs` call

### Fixed
- Minor fix to `autorize_params` method in omniauth strategies

## [0.1.8] - 2017-10-08
### Fixed
- Added timeout to the `Esi::Client#request` method

## [0.1.7] - 2017-10-08
### Added
- `timeout` attribute to the default Esi configuration
- `original_exception` attribute to `Esi::ApiError`
- `ApiRequestError` class

### Changed
- Upgraded `oauth2` dependency to `1.4`

## [0.1.5] - 2017-9-16
### Added
- activesupport and recursive-open-struct dependencies
- default SCOPES to the configuration object
- The `Client` method to the Esi module
- The `ApiInvalidAppClientKeysError` class
- The `scope` and `cache_duration` class attributes to `Esi::Calls::Base`
- A bunch of new call types to `Esi::Calls`
- ActiveSupport::Notification instrumentation to the `Esi::Client`
- `data` and `each` delegators to `Esi::Response`
- lib/omniauth/strategies/esi.rb

### Removed
- The `Characters`, `CharacterWallets`, `CharacterBlueprints`, `StructureOrders` call types.

## [0.1.2] - 2017-5-12
### Added
- Gem documentation to README.md
- Gem metadata to esi.gemspec
- lib/esi/access_token.rb
- lib/esi/calls.rb
- lib/esi/client.rb
- lib/esi/o_auth.rb
- lib/esi/response.rb
- default configuration and helper methods to lib/esi.rb

## 0.1.0 - 2017-3-13
### Added
- .gitignore
- .travis.yml
- Gemfile
- LICENSE.txt
- README.md
- Rakefile
- bin/console
- esi.gemspec
- lib/esi.rb
- lib/esi/version.rb

[Unreleased]: https://github.com/dhiemstra/esi/compare/v0.4.0...HEAD
[0.4.0]: https://github.com/dhiemstra/esi/compare/v0.3.6...v0.4.0
[0.3.6]: https://github.com/dhiemstra/esi/compare/v0.3.5...v0.3.6
[0.3.5]: https://github.com/dhiemstra/esi/compare/v0.2.34...v0.3.5
[0.2.34]: https://github.com/dhiemstra/esi/compare/v0.2.24...v0.2.34
[0.2.24]: https://github.com/dhiemstra/esi/compare/v0.2.23...v0.2.24
[0.2.23]: https://github.com/dhiemstra/esi/compare/v0.2.12...v0.2.23
[0.2.12]: https://github.com/dhiemstra/esi/compare/v0.2.11...v0.2.12
[0.2.11]: https://github.com/dhiemstra/esi/compare/v0.2.10...v0.2.11
[0.2.10]: https://github.com/dhiemstra/esi/compare/v0.2.9...v0.2.10
[0.2.9]: https://github.com/dhiemstra/esi/compare/v0.2.8...v0.2.9
[0.2.8]: https://github.com/dhiemstra/esi/compare/v0.2.7...v0.2.8
[0.2.7]: https://github.com/dhiemstra/esi/compare/v0.2.5...v0.2.7
[0.2.5]: https://github.com/dhiemstra/esi/compare/v0.2.4...v0.2.5
[0.2.4]: https://github.com/dhiemstra/esi/compare/v0.2.3...v0.2.4
[0.2.3]: https://github.com/dhiemstra/esi/compare/v0.2.2...v0.2.3
[0.2.2]: https://github.com/dhiemstra/esi/compare/v0.2.1...v0.2.2
[0.2.1]: https://github.com/dhiemstra/esi/compare/v0.2.0...v0.2.1
[0.2.0]: https://github.com/dhiemstra/esi/compare/v0.1.17...v0.2.0
[0.1.17]: https://github.com/dhiemstra/esi/compare/v0.1.16...v0.1.17
[0.1.16]: https://github.com/dhiemstra/esi/compare/v0.1.15...v0.1.16
[0.1.15]: https://github.com/dhiemstra/esi/compare/v0.1.14...v0.1.15
[0.1.14]: https://github.com/dhiemstra/esi/compare/v0.1.11...v0.1.14
[0.1.11]: https://github.com/dhiemstra/esi/compare/v0.1.10...v0.1.11
[0.1.10]: https://github.com/dhiemstra/esi/compare/v0.1.9...v0.1.10
[0.1.9]: https://github.com/dhiemstra/esi/compare/v0.1.8...v0.1.9
[0.1.8]: https://github.com/dhiemstra/esi/compare/v0.1.7...v0.1.8
[0.1.7]: https://github.com/dhiemstra/esi/compare/v0.1.5...v0.1.7
[0.1.5]: https://github.com/dhiemstra/esi/compare/v0.1.2...v0.1.5
[0.1.2]: https://github.com/dhiemstra/esi/compare/v0.1.0...v0.1.2
