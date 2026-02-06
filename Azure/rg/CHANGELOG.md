# Changelog

## [2026-02-06] - CLAUDE.md Standards Alignment

### Changed
- Updated AVM module version constraint from exact `0.2.2` to pessimistic `~> 0.2`
- Default resource group name now includes the map key as suffix (`rg-{project}-{env}-{location}-{key}`) to prevent name collisions when creating multiple resource groups

### Added
- `resource_group_locations` output to match upstream AVM module's `location` output

### Removed
- Unused `local.names` block (default name now computed inline)
