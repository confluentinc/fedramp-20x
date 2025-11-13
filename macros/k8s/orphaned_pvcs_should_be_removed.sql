{% macro orphaned_pvcs_should_be_removed(framework, check_id) %}
  {{ return(adapter.dispatch('orphaned_pvcs_should_be_removed')(framework, check_id)) }}
{% endmacro %}

{% macro default__orphaned_pvcs_should_be_removed(framework, check_id) %}{% endmacro %}

{% macro bigquery__orphaned_pvcs_should_be_removed(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Kubernetes PersistentVolumeClaims should be bound to volumes' as title,
    concat(context, '/', namespace, '/', name) as identifier,
    JSON_OBJECT() as metadata,
    case when
        JSON_VALUE(status.phase) in ('Pending', 'Available')
        and DATETIME_DIFF(CURRENT_DATETIME(), DATETIME(creation_timestamp), DAY) > 7
        then 'fail'
        else 'pass'
    end as status,
    JSON_OBJECT() as tags
from {{ full_table_name("k8s_core_pvcs") }}
where {{ partition_filter() }}
{% endmacro %}
