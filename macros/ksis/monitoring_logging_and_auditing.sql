{% macro monitoring_logging_and_auditing() %}
-- KSI-MLA: Monitoring, Logging, and Auditing
-- KSI-MLA-01: Operate a Security Information and Event Management (SIEM) or similar system(s) for centralized, tamper-resistent logging of events, activities, and changes.
({{ aws_cisv3_mapping('KSI-MLA-01', '1.0', '3.1') }}) -- CloudTrail is enabled in all regions
    {{ union() }}
({{ aws_cisv3_mapping('KSI-MLA-01', '1.1', '3.8') }}) -- CloudTrail Write events are enabled
    {{ union() }}
({{ aws_cisv3_mapping('KSI-MLA-01', '1.2', '3.9') }}) -- CloudTrail Read events are enabled
    {{ union() }}
({{ aws_cisv3_mapping('KSI-MLA-01', '1.3', '3.7') }}) -- CloudTrail Read events are enabled
    {{ union() }}

-- KSI-MLA-02: Regularly review and audit logs.
-- KSI-MLA-03: Rapidly detect and respond to vulnerabilities following requirements and recommendations in the FedRAMP Vulnerability Response and Detection standard
({{ ec2_instances_should_be_scanned_by_inspector('KSI-MLA-03', '1.0')}})
    {{ union() }}
({{ inspector_vulnerabilities_should_be_resolved_in_sla('KSI-MLA-03', '1.1') }})
    {{ union() }}

-- KSI-MLA-05: Perform Infrastructure as Code and configuration evaluation and testing.
({{ jira_should_be_used_for_tracking_vulnerabilities('KSI-MLA-06', '1.0') }})
    {{ union() }}
({{ jira_should_have_continuous_monitoring_project('KSI-MLA-06', '1.1') }})
    {{ union() }}

-- KSI-MLA-07: Maintain a list of information resources and event types that will be monitored, logged, and audited.
-- KSI-MLA-08: Use a least-privileged, role and attribute-based, and just-in-time access authorization model for access to log data.
({{ eks_control_planes_should_use_oidc_access('KSI-MLA-08', '1.0') }})
    {{ union() }}
({{ iam_roles_for_engineer_access_use_saml('KSI-MLA-08', '1.1') }})
    {{ union() }}
({{ okta_system_logs_just_in_time_access('KSI-MLA-08', '1.2', var('logging_applications')) }})
{% endmacro %}

