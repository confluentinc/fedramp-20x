{% macro unused_gcp_static_ips_should_be_released(framework, check_id) %}
  {{ return(adapter.dispatch('unused_gcp_static_ips_should_be_released')(framework, check_id)) }}
{% endmacro %}

{% macro default__unused_gcp_static_ips_should_be_released(framework, check_id) %}{% endmacro %}

{% macro bigquery__unused_gcp_static_ips_should_be_released(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'GCP static IP addresses should be in use' as title,
    project_id,
    name as resource_id,
    case when
        status = 'RESERVED'
        and DATETIME_DIFF(
            CURRENT_DATETIME(), 
            DATETIME(PARSE_TIMESTAMP('%Y-%m-%dT%H:%M:%S.%fZ', creation_timestamp)),
            DAY
        ) > 7
        then 'fail'
        else 'pass'
    end as status
from {{ full_table_name("gcp_compute_addresses") }}
where {{ partition_filter() }}
{% endmacro %}
