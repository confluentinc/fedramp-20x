{% macro cybersecurity_education() %}
-- KSI-CED: Cybersecurity Education
-- KSI-CED-01: Require and monitor the effectiveness of training given to all employees on policies, procedures, and security-related topics.
({{ workday_employee_should_have_completed_security_training('KSI-CED-01', '1.0') }})
    {{ union() }}
({{ workday_employee_should_have_completed_acceptable_use_policy_training('KSI-CED-01', '1.1') }})
    {{ union() }}
({{ workday_employee_should_have_completed_data_classification_training('KSI-CED-01', '1.2') }})
    {{ union() }}
-- KSI-CED-02: Require and monitor the effectiveness of role-specific training for high risk roles, including at least roles with privileged access.
({{ okta_active_users_should_have_valid_training('KSI-CED-02', '1.0') }})
    {{ union() }}
-- KSI-CED-03: Require and monitor the effectiveness of role-specific training provided to development and engineering staff that covers best practices for delivering secure software.
({{ workday_engineer_should_have_completed_engineering_security_training('KSI-CED-03', '1.0') }})
-- KSI-CED-04: Require and monitor the effectiveness of role-specific training to staff involved with incident response or disaster recovery.
{% endmacro %}

