{% macro kubernetes_resources_backing_albs() %}
  {{ return(adapter.dispatch('kubernetes_resources_backing_albs')()) }}
{% endmacro %}

{% macro default__kubernetes_resources_backing_albs() %}{% endmacro %}

{% macro bigquery__kubernetes_resources_backing_albs() %}
  with k8s_resources as (
    (
      select
          ing.context,
          ing.namespace,
          ing.name,
          'ingress' as k8s_resource_type,
          JSON_EXTRACT_SCALAR(lb, '$.hostname') as hostname,
        from {{ full_table_name("k8s_networking_ingresses") }} as ing,
         UNNEST(JSON_QUERY_ARRAY(status_load_balancer, '$.ingress' )) as lb
        where {{ partition_filter() }}
        and lb is not null
    )
        {{ union() }}
    (
      select
        svc.context,
        svc.namespace,
        svc.name,
        'service' as k8s_resource_type,
        JSON_EXTRACT_SCALAR(lb, '$.hostname') as hostname,
      from {{ full_table_name("k8s_core_services") }} as svc,
        UNNEST(JSON_QUERY_ARRAY(status_load_balancer, '$.ingress' )) as lb
      where {{ partition_filter() }}
        and svc.spec_type = 'LoadBalancer'
        and lb is not null
    )
)
SELECT
    'Kubernetes services backing Application Load Balancers' as title,
    k8s.context as account_id,
    CONCAT(k8s.context, '.', k8s.namespace, '.', k8s_resource_type, '.', k8s.name) as resource_id,
    k8s_resource_type as resource_type,
    'publicly_accessible' as reachability_type,
    ingress_rules.from_port as from_port,
    ingress_rules.to_port as to_port,
    CAST(ingress_rules.ip_protocol AS STRING) as protocol,
    alb.dns_name as endpoint,
    'dns_name' as endpoint_type
FROM
    k8s_resources as k8s
LEFT JOIN {{ full_table_name("aws_elbv2_load_balancers") }} as alb
    ON k8s.hostname = alb.dns_name
LEFT JOIN UNNEST(alb.security_groups) AS security_group
LEFT JOIN {{ ref("aws_compliance__security_group_ingress_rules") }} as ingress_rules
    ON JSON_VALUE(security_group, "$.GroupId") = ingress_rules.id
WHERE {{ partition_filter() }}
    AND alb.scheme = 'internet-facing'
    AND ingress_rules.id IS NOT NULL
    AND ingress_rules.ip = "0.0.0.0/0"
    {% endmacro %}
