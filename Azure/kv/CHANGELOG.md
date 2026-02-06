# Changelog

## [2026-02-06] - CLAUDE.md Standards Alignment

### Changed
- Updated AVM module version constraint from exact `0.10.2` to pessimistic `~> 0.10`
- Reformatted `outputs.tf` with proper descriptions and multi-line style for consistency
- Reformatted `versions.tf` to match multi-line style used across all modules
- Changed `key_vault_uris` output to use upstream `uri` output directly instead of `resource.vault_uri`

### Added
- `key_vault_names` output for consistency with other modules
