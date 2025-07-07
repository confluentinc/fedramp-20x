{% macro jira_should_be_used_for_tracking_vulnerabilities(framework, check_id) %}
  {{ return(adapter.dispatch('jira_should_be_used_for_tracking_vulnerabilities')(framework, check_id)) }}
{% endmacro %}

{% macro default__jira_should_be_used_for_tracking_vulnerabilities(framework, check_id) %}{% endmacro %}

{% macro bigquery__jira_should_be_used_for_tracking_vulnerabilities(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Jira issues are created for tracking and remediating vulnerabilities' as title,
    key as identifier,
    JSON_OBJECT() as metadata,
    case
        when JSON_VALUE(fields, '$.status.name') in ('Done', 'Blocked By Vendor', 'DR Approved')
            then 'pass'
        else 'fail'
    end as status,
    JSON_OBJECT() as tags
from {{ full_table_name("jira_issues") }}
where {{ partition_filter() }}
and DATE(JSON_VALUE(fields, '$.created')) >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
and DATE(JSON_VALUE(fields, '$.created')) <= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
and key LIKE '{{ var("continuous_monitoring_jira_project") }}-%'

{% endmacro %}