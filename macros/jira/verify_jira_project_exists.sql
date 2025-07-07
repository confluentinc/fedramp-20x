{% macro verify_jira_project_exists(framework, check_id, description, project) %}
  {{ return(adapter.dispatch('verify_jira_project_exists')(framework, check_id, description, project)) }}
{% endmacro %}

{% macro default__verify_jira_project_exists(framework, check_id, description, project) %}{% endmacro %}

{% macro bigquery__verify_jira_project_exists(framework, check_id, description, project) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Jira project should exist for {{ description }}' as title,
    '{{ project }}' as identifier,
    JSON_OBJECT() as metadata,
    case when exists (
        select 1 from {{ full_table_name("jira_projects") }}
        where {{ partition_filter() }} and name = '{{ project }}'
        limit 1
    ) then 'pass' else 'fail' end as status,
    JSON_OBJECT() as tags
{% endmacro %}