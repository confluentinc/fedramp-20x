-- Ensure that all EKS clusters have image verifier installed
{% macro k8s_clusters_should_have_enforcement_webhooks(framework, check_id) %}
  {{ return(adapter.dispatch('k8s_clusters_should_have_enforcement_webhooks')(framework, check_id)) }}
{% endmacro %}

{% macro default__k8s_clusters_should_have_enforcement_webhooks(framework, check_id) %}{% endmacro %}

{% macro bigquery__k8s_clusters_should_have_enforcement_webhooks(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Kubernetes clusters should have image verifier installed' as title,
    cluster.arn as identifier,
    null as metadata,
    case
        when vw.name is not null then 'pass'
        else 'fail'
    end as status,
    cluster.tags as tags
from {{ full_table_name("aws_eks_clusters") }} as cluster
right join {{ full_table_name("k8s_admissionregistration_validating_webhook_configurations") }} as vw
on cluster.name = vw.context
where TIMESTAMP_TRUNC(cluster._cq_sync_time, DAY) = TIMESTAMP(CURRENT_DATE())
{% endmacro %}
