# Changelog

## [2026-02-06] - CLAUDE.md Standards Alignment

### Changed
- Updated AVM module version constraint from exact `0.17.1` to pessimistic `~> 0.17`
- Simplified `timeouts` passthrough to rely on upstream module defaults instead of redundant hardcoded values
- Fixed VNet-level `ipam_pools` variable to match upstream: renamed `pool_id` to `id`, made `prefix_length` required, removed `allocation_type` (only valid at subnet level)

### Added
- VNet-level `ipam_pools` passthrough in `main.tf` (was defined in variables but never passed to the AVM module)
- `vnet_locations` output for consistency with other modules
- `vnet_address_spaces` output to expose VNet address spaces
- `vnet_peerings` output to expose VNet peering information
