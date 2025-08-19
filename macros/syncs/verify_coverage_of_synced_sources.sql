{% macro verify_coverage_of_synced_sources(framework, check_id) %}
  {{ return(adapter.dispatch('verify_coverage_of_synced_sources')(framework, check_id)) }}
{% endmacro %}

{% macro default__verify_coverage_of_synced_sources(framework, check_id) %}{% endmacro %}

{% macro bigquery__verify_coverage_of_synced_sources(framework, check_id) %}
with source_list as (
  (
    select concat(name, '-', region) as name from cloudquery.aws_eks_clusters
    where {{ partition_filter() }}
  ) {{ union() }} (
    select concat('gke-', name) as name from cloudquery.gcp_container_clusters
    where {{ partition_filter() }}
  )
)
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Data syncs should import all covered resources' as title,
    source_list.name as identifier,
    JSON_OBJECT() as metadata,
    case
        when css._cq_source_name is null then 'fail'
        else 'pass'
    end as status
from source_list
left join {{ full_table_name("cloudquery_sync_summaries") }} css
on source_list.name = css._cq_source_name
and {{ partition_filter("css") }}
    {% endmacro %}