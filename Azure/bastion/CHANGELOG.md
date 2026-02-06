# Changelog

## [2026-02-06] - CLAUDE.md Standards Alignment

### Changed
- Updated AVM module version constraint from exact `0.9.0` to pessimistic `~> 0.9`
- Fixed `zones` default to `["1", "2", "3"]` to match upstream AVM module (was incorrectly defaulting to `[]`)
- Made `ip_configuration` conditional: `null` for Developer SKU, constructed for all other SKUs (matches upstream behavior)
- Changed `subnet_id` from required to optional (not needed for Developer SKU)

### Added
- `bastion_dns_names` output to expose Bastion Host FQDNs (matches upstream `dns_name` output)
