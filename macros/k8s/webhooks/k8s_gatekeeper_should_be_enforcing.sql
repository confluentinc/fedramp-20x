-- Ensure that all of our Gatekeeper policies are in enforcement mode
{% macro k8s_gatekeeper_should_be_enforcing(framework, check_id) %}
  {{ return(adapter.dispatch('k8s_gatekeeper_should_be_enforcing')(framework, check_id)) }}
{% endmacro %}

{% macro default__k8s_gatekeeper_should_be_enforcing(framework, check_id) %}{% endmacro %}

{% macro bigquery__k8s_gatekeeper_should_be_enforcing(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Kubernetes clusters should have gatekeeper in enforcement mode' as title,
    cluster.arn as identifier,
    null as metadata,
    case
        when JSON_VALUE(cr.spec, '$.enforcementAction') = 'deny' then 'pass'
        else 'fail'
    end as status,
    cluster.tags as tags
from {{ full_table_name("aws_eks_clusters") }} as cluster
right join {{ full_table_name("k8s_custom_resources") }} as cr
on cluster.name = cr.context
where cr.kind in (
    'K8sExternalDataCosign',
    'K8sExternalDataCosignEphemeralContainers',
    'K8sExternalDataCosignInitContainers'
)
and TIMESTAMP_TRUNC(cluster._cq_sync_time, DAY) = TIMESTAMP(CURRENT_DATE())
    {% endmacro %}
