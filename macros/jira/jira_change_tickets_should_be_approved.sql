{% macro jira_change_tickets_should_be_approved(framework, check_id) %}
  {{ return(adapter.dispatch('jira_change_tickets_should_be_approved')(framework, check_id)) }}
{% endmacro %}

{% macro default__jira_change_tickets_should_be_approved(framework, check_id) %}{% endmacro %}

{% macro bigquery__jira_change_tickets_should_be_approved(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Change Management tickets in Jira should be approved by appropriate parties' as title,
    key as identifier,
    JSON_OBJECT() as metadata,
    case
    when exists (
      select 1 from unnest(JSON_QUERY_ARRAY(changelog, "$.histories")) as change, unnest(JSON_QUERY_ARRAY(change, "$.items")) as item
      where JSON_VALUE(item, '$.toString') IN ({{ to_sql_list(var("change_approval_steps"))}})
    ) then 'pass'
    else 'fail'
end as status,
    JSON_OBJECT() as tags
from {{ full_table_name("jira_issues") }}
where {{ partition_filter() }}
and DATE(JSON_VALUE(fields, '$.created')) >= DATE_SUB(CURRENT_DATE(), INTERVAL 90 DAY)
and DATE(JSON_VALUE(fields, '$.created')) <= DATE_SUB(CURRENT_DATE(), INTERVAL 30 DAY)
and key LIKE '{{ var("change_management_jira_project") }}-%'
and JSON_VALUE(fields, '$.status.name') IN ('Done', 'Work In Progress')
{% endmacro %}