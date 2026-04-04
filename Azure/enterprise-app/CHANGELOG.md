# Changelog

## [2026-04-04] - Initial Release

### Added
- `azuread_service_principal` resource to create enterprise applications from existing app registrations
- `azuread_app_role_assignment` resource to assign app roles to users, groups, or service principals
- `azuread_service_principal_delegated_permission_grant` resource for admin consent of OAuth2 delegated scopes
- `app_role_assignment_required` support to restrict access to explicitly assigned principals
- `preferred_single_sign_on_mode` support for SAML, OIDC, and password SSO configuration
- Outputs for service principal object IDs, client IDs, role assignments, and permission grants
