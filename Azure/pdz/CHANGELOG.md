# Changelog

## [2026-02-06] - CLAUDE.md Standards Alignment

### Changed
- Updated AVM module version constraint from exact `0.4.4` to pessimistic `~> 0.4`
- Simplified timeouts in main.tf from redundant hardcoded defaults to `try(each.value.timeouts, {})`
- Removed hardcoded timeout defaults from variable definitions to track upstream defaults
- Improved variable descriptions for `location_short`, `environment`, `location`, `project_name`

### Added
- `lock` variable and passthrough for resource lock support (CanNotDelete/ReadOnly)
- Missing `multiplier` and `randomization_factor` fields to `retry` variable

### Fixed
- Timeouts key mismatch: main.tf fallback used `virtual_network_links` but upstream expects `vnet_links`
