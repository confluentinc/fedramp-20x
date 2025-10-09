{% macro eks_control_planes_should_use_oidc_access(framework, check_id) %}
  {{ return(adapter.dispatch('eks_control_planes_should_use_oidc_access')(framework, check_id)) }}
{% endmacro %}

{% macro default__eks_control_planes_should_use_oidc_access(framework, check_id) %}{% endmacro %}

{% macro bigquery__eks_control_planes_should_use_oidc_access(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'EKS Clusters should use OIDC access controls' as title,
    eks.arn as identifier,
    JSON_OBJECT() as metadata,
    case when oidc.arn IS NOT NULL
        then 'pass'
        else 'fail'
    end as status,
    eks.tags
from {{ full_table_name("aws_eks_clusters") }} as eks
left join {{ full_table_name("aws_eks_cluster_oidc_identity_provider_configs") }} as oidc
    on eks.arn = oidc.cluster_arn
    and {{ partition_join("eks", "oidc") }}
    and oidc.identity_provider_config_name LIKE '%okta%'
    and UPPER(oidc.status) = 'ACTIVE'
where {{ partition_filter("eks") }}
{% endmacro %}
