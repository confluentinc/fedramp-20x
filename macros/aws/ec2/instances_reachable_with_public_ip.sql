{% macro instances_reachable_with_public_ip() %}
  {{ return(adapter.dispatch('instances_reachable_with_public_ip')()) }}
{% endmacro %}

{% macro default__instances_reachable_with_public_ip() %}{% endmacro %}

{% macro bigquery__instances_reachable_with_public_ip() %}
SELECT
    'EC2 Instances with a public IP address' as title,
    aws_ec2_instances.account_id,
    aws_ec2_instances.arn AS resource_id,
    'aws_ec2_instances' as resource_type,
    'instance_with_public_ip' as reachability_type,
    ingress_rules.from_port as from_port,
    ingress_rules.to_port as to_port,
    CAST(ingress_rules.ip_protocol AS STRING) as protocol,
    public_ip_address as endpoint,
    'ip_address' as endpoint_type
FROM
    {{ full_table_name("aws_ec2_instances") }},
    UNNEST(JSON_QUERY_ARRAY(security_groups, "$")) as security_group
LEFT JOIN {{ ref("aws_compliance__security_group_ingress_rules") }} as ingress_rules
    ON JSON_VALUE(security_group, "$.GroupId") = ingress_rules.id
WHERE {{ partition_filter() }}
AND public_ip_address IS NOT NULL
AND ingress_rules.id IS NOT NULL
AND ingress_rules.ip = "0.0.0.0/0"
    {% endmacro %}
