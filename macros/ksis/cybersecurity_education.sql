{% macro cybersecurity_education() %}
-- KSI-CED: Cybersecurity Education
-- KSI-CED-01: Ensure all employees receive security and privacy awareness training, incident response training, and are familiar with all relevant policies and procedures.
({{ okta_active_users_should_have_valid_training('KSI-CED-01', '1.0') }})
    {{ union() }}
-- KSI-CED-02: Require role-specific training for high risk roles, including at least roles with privileged access.
({{ okta_active_users_should_have_valid_training('KSI-CED-02', '1.0') }})
-- KSI-CED-03: Require role-specific training for development and engineering staff covering best practices for delivering secure software.
{% endmacro %}

