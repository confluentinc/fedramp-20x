{% macro change_management() %}
-- KSI-CMT: Change Management
-- KSI-CMT-01: Log and monitor service modifications
({{ organization_cloudtrail_should_emit_events_to_s3('KSI-CMT-01', '1.0') }})
    {{ union() }}
({{ eks_control_planes_should_log_all_events('KSI-CMT-01', '1.1') }})
    {{ union() }}
-- KSI-CMT-02: Execute changes through redeployment of version controlled immutable resources rather than direct modification wherever possible.
-- KSI-CMT-03: Implement persistent automated testing and validation of changes
-- KSI-CMT-04: Consistently follow a documented change management procedure
-- KSI-CMT-05: Evaluate the risk and potential impact of any change.
({{ jira_should_have_change_management_project('KSI-CMT-05', '1.0') }})
    {{ union() }}
({{ jira_change_tickets_should_be_approved('KSI-CMT-05', '1.1') }})
{% endmacro %}

