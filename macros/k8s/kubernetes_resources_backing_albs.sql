{% macro kubernetes_ingresses_backing_albs() %}
  {{ return(adapter.dispatch('kubernetes_ingresses_backing_albs')()) }}
{% endmacro %}

{% macro default__kubernetes_ingresses_backing_albs() %}{% endmacro %}

{% macro bigquery__kubernetes_ingresses_backing_albs() %}
SELECT
    'Kubernetes services backing Application Load Balancers' as title,
    account_id,
    arn AS resource_id,
    'kubernetes_services' as resource_type,
    'publicly_accessible' as reachability_type,
    alb.dns_name as endpoint,
    'dns_name' as endpoint_type
FROM
    {{ full_table_name("aws_") }}
WHERE {{ partition_filter() }}
  AND publicly_accessible = true
    {% endmacro %}
