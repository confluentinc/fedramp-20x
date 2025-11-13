{% macro kubernetes_ingresses_should_enforce_tls(framework, check_id) %}
  {{ return(adapter.dispatch('kubernetes_ingresses_should_enforce_tls')(framework, check_id)) }}
{% endmacro %}

{% macro default__kubernetes_ingresses_should_enforce_tls(framework, check_id) %}{% endmacro %}

{% macro bigquery__kubernetes_ingresses_should_enforce_tls(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Kubernetes ingress resources should enforce TLS' as title,
    context,
    concat(namespace, '/', name) as resource_id,
    case when
        JSON_EXTRACT(spec, '$.tls') is null
        or JSON_EXTRACT_ARRAY(spec, '$.tls') = []
        then 'fail'
        else 'pass'
    end as status
from {{ full_table_name("k8s_networking_ingresses") }}
where {{ partition_filter() }}
{% endmacro %}
