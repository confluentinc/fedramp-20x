{% macro kubernetes_resources_reachable_from_api_gateway() %}
  {{ return(adapter.dispatch('kubernetes_resources_reachable_from_api_gateway')()) }}
{% endmacro %}

{% macro default__kubernetes_resources_reachable_from_api_gateway() %}{% endmacro %}

{% macro bigquery__kubernetes_resources_reachable_from_api_gateway() %}
WITH gateway_args as (
  SELECT
    *,
    REGEXP_EXTRACT(SPLIT(container_arg, "=")[SAFE_OFFSET(1)], r'^(?:[^:]+:\/\/\/?)?([^\/:]+)?') as addr,
    FROM {{ full_table_name("k8s_apps_deployments") }}, UNNEST(JSON_VALUE_ARRAY(spec_template, '$.spec.containers[0].args')) as container_arg
    WHERE {{ partition_filter() }}
    AND namespace = '{{ var("api_gateway_namespace") }}'
    AND name = '{{ var("api_gateway_service_name") }}'
    AND container_arg LIKE '%addr%'
),
cleaned_hosts as (
    SELECT
    *,
    case
      {% for suffix in var('api_gateway_ignored_suffixes') %}
      when ENDS_WITH(addr, '{{ suffix }}') THEN SUBSTR(addr, 1, LENGTH(addr) - LENGTH('{{ suffix }}'))
      {% endfor %}
        ELSE addr
      END AS cleaned_host
    from gateway_args
),
select
    'Kubernetes services reachable from API Gateway' as title,
    cleaned_hosts.context as account_id,
    CONCAT(cleaned_hosts.context, '.', COALESCE(SPLIT(cleaned_host, '.')[SAFE_OFFSET(1)], '{{ var("api_gateway_namespace") }}'), '.service.', SPLIT(cleaned_host, '.')[SAFE_OFFSET(0)]) as resource_id,
    'service' as resource_type,
    'api_gateway_proxy' as reachability_type,
    NULL as from_port,
    NULL as to_port,
    '' as protocol,
    '' as endpoint,
    'api_gateway' as endpoint_type
from cleaned_hosts
    {% endmacro %}

