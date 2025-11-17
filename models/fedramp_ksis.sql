{% set incident_tracking_jira_project = var('incident_tracking_jira_project') %}
{% set continuous_monitoring_jira_project = var('continuous_monitoring_jira_project') %}
{% set security_jira_project = var('security_jira_project') %}

with
    aggregated as (
        ({{ minimum_assessment_scope() }})
        {{ union() }}
        ({{ change_management() }})
        {{ union() }}
        ({{ cybersecurity_education() }})
        {{ union() }}
        ({{ cloud_native_architecture() }})
        {{ union() }}
        ({{ identity_and_access_management() }})
        {{ union() }}
        ({{ incident_reporting() }})
        {{ union() }}
        ({{ monitoring_logging_and_auditing() }})
        {{ union() }}
        ({{ policy_and_inventory() }})
        {{ union() }}
        ({{ recovery_planning() }})
        {{ union() }}
        ({{ service_configuration() }})
        {{ union() }}
        ({{ third_party_information_resources() }})

    )
select
    {{ gen_timestamp() }},
    aggregated.*
from aggregated
