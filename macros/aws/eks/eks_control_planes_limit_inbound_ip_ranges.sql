{% macro eks_control_planes_limit_inbound_ip_ranges(framework, check_id) %}
  {{ return(adapter.dispatch('eks_control_planes_limit_inbound_ip_ranges')(framework, check_id)) }}
{% endmacro %}

{% macro default__eks_control_planes_limit_inbound_ip_ranges(framework, check_id) %}{% endmacro %}

{% macro bigquery__eks_control_planes_limit_inbound_ip_ranges(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'EKS Clusters control planes should limit inbound IP Ranges' as title,
    eks.arn as identifier,
    JSON_OBJECT() as metadata,
    case when ARRAY_LENGTH(JSON_VALUE_ARRAY(eks.resources_vpc_config, '$.PublicAccessCidrs')) > 0
        then 'pass'
        else 'fail'
    end as status,
    eks.tags
from {{ full_table_name("aws_eks_clusters") }} eks
where {{ partition_filter() }}
    {% endmacro %}
