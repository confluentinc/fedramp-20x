{% macro k8s_image_enforcement_policies_should_not_ignore_failures(framework, check_id) %}
  {{ return(adapter.dispatch('k8s_image_enforcement_policies_should_not_ignore_failures')(framework, check_id)) }}
{% endmacro %}

{% macro default__k8s_image_enforcement_policies_should_not_ignore_failures(framework, check_id) %}{% endmacro %}

{% macro bigquery__k8s_image_enforcement_policies_should_not_ignore_failures(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Kubernetes clusters enforcement policies should not ignore failures' as title,
    cluster.arn as identifier,
    null as metadata,
    case
        when UPPER(JSON_VALUE(webhook, "$.failurePolicy")) = 'FAIL' then 'pass'
        else 'fail'
        end as status,
    cluster.tags as tags
from {{ full_table_name("aws_eks_clusters") }} as cluster
right join {{ full_table_name("k8s_admissionregistration_validating_webhook_configurations") }} as vw
on cluster.name = vw.context
LEFT JOIN UNNEST(JSON_EXTRACT_ARRAY(vw.webhooks)) AS webhook
where vw.name = '{{ var("image_signing_webhook") }}'
  and TIMESTAMP_TRUNC(cluster._cq_sync_time, DAY) = TIMESTAMP(CURRENT_DATE())
    {% endmacro %}
