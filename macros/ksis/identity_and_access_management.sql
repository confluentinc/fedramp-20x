{% macro identity_and_access_management() %}
-- KSI-IAM: Identity and Access Management
-- KSI-IAM-01: Enforce multi-factor authentication (MFA) using methods that are difficult to intercept or impersonate (phishing-resistant MFA) for all user authentication.
({{ okta_users_require_mfa('KSI-IAM-01', '1.0')}})
    {{ union() }}
({{ okta_apps_should_require_multifactor_authentication('KSI-IAM-01', '1.1') }})
    {{ union() }}

-- KSI-IAM-02: Use secure passwordless methods for user authentication and authorization when feasible, otherwise enforce strong passwords with MFA.
({{ okta_users_require_strong_password('KSI-IAM-02', '1.0') }})
    {{ union() }}

-- KSI-IAM-03: Enforce appropriately secure authentication methods for non-user accounts and services.
({{ okta_service_accounts_have_secure_authentication('KSI-IAM-03', '1.0') }})
    {{ union() }}

-- KSI-IAM-04: Use a least-privileged, role and attribute-based, and just-in-time security authorization model for all user and non-user accounts and services.
({{ iam_root_user_has_no_access_keys('KSI-IAM-04', '1.0') }})
    {{ union() }}

-- KSI-IAM-05: Configure identity and access management with measures that always verify each user or device can only access the resources they need.
({{ okta_behavior_rules_detect_compromise('KSI-IAM-05', '1.0') }})
    {{ union() }}

-- KSI-IAM-06: Automatically disable or otherwise secure accounts with privileged access in response to suspicious activity
({{ okta_behavior_rules_suspicious_activity_requires_mfa('KSI-IAM-06', '1.0') }})
    {{ union() }}

-- KSI-IAM-07: Securely manage the lifecycle and privileges of all accounts, roles, and groups, using automation.
({{ okta_users_should_not_be_manually_created('KSI-IAM-07', '1.0') }})
    {{ union() }}
({{ iam_roles_for_engineer_access_use_saml('KSI-IAM-07', '1.1') }})
{% endmacro %}

