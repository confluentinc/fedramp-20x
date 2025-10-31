

{% macro jira_tickets_created_for_security_configuration_updates(framework, check_id) %}
  {{ return(adapter.dispatch('jira_tickets_created_for_security_configuration_updates')(framework, check_id)) }}
{% endmacro %}

{% macro default__jira_tickets_created_for_security_configuration_updates(framework, check_id) %}{% endmacro %}

{% macro bigquery__jira_tickets_created_for_security_configuration_updates(framework, check_id) %}

select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Jira issues are created for security configuration updates' as title,
    null as identifier,
    JSON_OBJECT('count', count(*)) as metadata,
    case
        when count(*) > 0
        then 'pass'
        else 'fail'
    end as status,
    JSON_OBJECT() as tags
from {{ full_table_name('jira_issues') }}
where key like '{{ var("continuous_monitoring_jira_project") }}-%'
and exists (
    select 1 from unnest(JSON_VALUE_ARRAY(fields, '$.labels')) as label where label = 'fedramp-misconfig'
)
and {{ partition_filter() }}
{% endmacro %}