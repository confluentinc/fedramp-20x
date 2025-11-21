{% macro cybersecurity_education() %}
-- KSI-CED: Cybersecurity Education
-- KSI-CED-01: Require and monitor the effectiveness of training given to all employees on policies, procedures, and security-related topics.
({{ okta_active_users_should_have_valid_training('KSI-CED-01', '1.0') }})
    {{ union() }}
-- KSI-CED-02: Require and monitor the effectiveness of role-specific training for high risk roles, including at least roles with privileged access.
({{ okta_active_users_should_have_valid_training('KSI-CED-02', '1.0') }})
-- KSI-CED-03: Require and monitor the effectiveness of role-specific training provided to development and engineering staff that covers best practices for delivering secure software.
-- KSI-CED-04: Require and monitor the effectiveness of role-specific training to staff involved with incident response or disaster recovery.
{% endmacro %}

