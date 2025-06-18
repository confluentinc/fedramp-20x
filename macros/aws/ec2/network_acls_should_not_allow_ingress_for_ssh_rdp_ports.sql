{% macro network_acls_should_not_allow_ingress_for_ssh_rdp_ports(framework, check_id) %}
  {{ return(adapter.dispatch('network_acls_should_not_allow_ingress_for_ssh_rdp_ports')(framework, check_id)) }}
{% endmacro %}

{% macro default__network_acls_should_not_allow_ingress_for_ssh_rdp_ports(framework, check_id) %}{% endmacro %}

{% macro bigquery__network_acls_should_not_allow_ingress_for_ssh_rdp_ports(framework, check_id) %}
WITH bad_entries as (
SELECT
    DISTINCT
    arn
FROM 
    {{ full_table_name("aws_ec2_network_acls") }},
UNNEST(JSON_QUERY_ARRAY(entries)) AS entry
WHERE 
    CAST(JSON_VALUE(entry.Egress) AS STRING) = 'false'
    AND CAST(JSON_VALUE(entry.Protocol) AS STRING) = '6'
    AND CAST(JSON_VALUE(entry.RuleAction) AS STRING) = 'allow'
    AND (
        CAST(JSON_VALUE(entry.PortRange.From) AS INT64) IN (22, 3389) 
        OR CAST(JSON_VALUE(entry.PortRange.To) AS INT64) IN (22, 3389)
    )
    AND (
        CAST(JSON_VALUE(entry.CidrBlock) AS STRING) = '0.0.0.0/0' 
        OR CAST(JSON_VALUE(entry.Ipv6CidrBlock) AS STRING) = '::/0'
    and {{ partition_filter("aws_ec2_network_acls") }}
)
)
SELECT
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'Network ACLs should not allow ingress from 0.0.0.0/0 to port 22 or port 3389' as title,
    a.account_id,
    a.arn as resource_id,
    CASE
        WHEN b.arn is not null THEN 'fail'
        ELSE 'pass'
    END as status
FROM
    {{ full_table_name("aws_ec2_network_acls") }} a
LEFT JOIN bad_entries b
    ON a.arn = b.arn
where {{ partition_filter("a") }}
{% endmacro %}
