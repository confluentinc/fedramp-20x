{% macro incident_reporting() %}
-- KSI-INR: Incident Response
-- KSI-INR-01: Respond to incidents according to FedRAMP requirements and cloud service provider policies
-- KSI-INR-02: Maintain a log of incidents and periodically review past incidents for patterns or vulnerabilities.
({{ jira_should_have_security_project('KSI-INR-02', '1.0') }})
    {{ union() }}
({{ jira_should_have_incident_tracking_project('KSI-INR-02', '1.1') }})

-- KSI-INR-03: Generate after action reports and regularly incorporate lessons learned into operations.

{% endmacro %}

