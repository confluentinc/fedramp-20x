{% macro unattached_gcp_disks_should_be_removed(framework, check_id) %}
  {{ return(adapter.dispatch('unattached_gcp_disks_should_be_removed')(framework, check_id)) }}
{% endmacro %}

{% macro default__unattached_gcp_disks_should_be_removed(framework, check_id) %}{% endmacro %}

{% macro bigquery__unattached_gcp_disks_should_be_removed(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'GCP persistent disks should be attached to compute instances' as title,
    name as identifier,
    JSON_OBJECT() as metadata,
    case when
        status = 'READY'
        and users is null
        and last_detach_timestamp is not null
        and DATETIME_DIFF(
            CURRENT_DATETIME(), 
            DATETIME(PARSE_TIMESTAMP('%Y-%m-%dT%H:%M:%S.%fZ', last_detach_timestamp)),
            DAY
        ) > 7
        then 'fail'
        else 'pass'
    end as status,
    JSON_OBJECT() as tags
from {{ full_table_name("gcp_compute_disks") }}
where {{ partition_filter() }}
{% endmacro %}
