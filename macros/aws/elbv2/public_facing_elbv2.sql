{% macro public_facing_elbv2() %}
  {{ return(adapter.dispatch('public_facing_elbv2')()) }}
{% endmacro %}

{% macro default__public_facing_elbv2() %}{% endmacro %}

{% macro bigquery__public_facing_elbv2() %}
SELECT
    'ALBs that are internet facing' as title,
    aws_elbv2_load_balancers.account_id,
    aws_elbv2_load_balancers.arn AS resource_id,
    'aws_elbv2_load_balancers' as resource_type,
    'alb_public_facing' as reachability_type,
    ingress_rules.from_port as from_port,
    ingress_rules.to_port as to_port,
    CAST(ingress_rules.ip_protocol AS STRING) as protocol,
    dns_name as endpoint,
    'dns_name' as endpoint_type
FROM
    {{ full_table_name("aws_elbv2_load_balancers") }},
    UNNEST(security_groups) AS security_group
LEFT JOIN {{ ref("aws_compliance__security_group_ingress_rules") }} as ingress_rules
    ON security_group = ingress_rules.id
WHERE {{ partition_filter() }}
  AND scheme = 'internet-facing'
  AND ingress_rules.id IS NOT NULL
  AND ingress_rules.ip = "0.0.0.0/0"
    {% endmacro %}
