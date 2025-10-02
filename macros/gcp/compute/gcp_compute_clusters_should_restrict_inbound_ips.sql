{% macro gcp_compute_clusters_should_restrict_inbound_ips(framework, check_id) %}
  {{ return(adapter.dispatch('gcp_compute_clusters_should_restrict_inbound_ips')(framework, check_id)) }}
{% endmacro %}

{% macro default__gcp_compute_clusters_should_restrict_inbound_ips(framework, check_id) %}{% endmacro %}

{% macro bigquery__gcp_compute_clusters_should_restrict_inbound_ips(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'GCP Compute clusters should restrict inbound IP ranges' as title,
    self_link as identifier,
    JSON_OBJECT() as metadata,
    case when
             (
                 JSON_VALUE(master_authorized_networks_config, '$.enabled') = 'true' AND
                 ARRAY_LENGTH(JSON_EXTRACT_ARRAY(master_authorized_networks_config, '$.cidr_blocks')) > 0
             ) or (
                JSON_VALUE(master_authorized_networks_config, '$.gcp_public_cidrs_access_enabled') = 'false'
             )
         then 'pass'
         else 'fail'
    end as status,
    JSON_OBJECT() as tags
from {{ full_table_name("gcp_container_clusters") }} lbs
WHERE {{ partition_filter() }}
    {% endmacro %}