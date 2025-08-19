{% macro verify_syncs_meet_success_threshold(framework, check_id) %}
  {{ return(adapter.dispatch('verify_syncs_meet_success_threshold')(framework, check_id)) }}
{% endmacro %}

{% macro default__verify_syncs_meet_success_threshold(framework, check_id) %}{% endmacro %}

{% macro bigquery__verify_syncs_meet_success_threshold(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Data sync jobs should meet success threshold' as title,
    _cq_source_name as identifier,
    JSON_OBJECT('resources', resources, 'errors', source_errors) as metadata,
    case
        when source_errors / resources < 0.1 then 'pass'
        else 'fail'
    end as status,
    JSON_OBJECT() as tags
from {{ full_table_name("cloudquery_sync_summaries") }}
where {{ partition_filter() }}
{% endmacro %}