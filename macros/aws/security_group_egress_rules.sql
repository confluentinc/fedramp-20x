{% macro security_group_egress_rules() %}
  {{ return(adapter.dispatch('security_group_egress_rules')()) }}
{% endmacro %}

{% macro default__security_group_egress_rules() %}{% endmacro %}

{% macro bigquery__security_group_egress_rules() %}
select 
    account_id,
    region,
    group_name,
    arn,
    group_id as id,
    vpc_id,
    CAST(JSON_VALUE(i.FromPort) AS INT64) AS from_port,
    CAST(JSON_VALUE(i.ToPort) AS INT64) AS to_port,
    JSON_VALUE(i.IpProtocol) AS ip_protocol,
    JSON_VALUE(ip_ranges.CidrIp) AS ip,
    JSON_VALUE(ip6_ranges.CidrIpv6) AS ip6
    from {{ full_table_name("aws_ec2_security_groups") }},
    UNNEST(JSON_QUERY_ARRAY(ip_permissions_egress)) AS i
    LEFT JOIN 
    UNNEST(JSON_QUERY_ARRAY(i.IpRanges)) AS ip_ranges ON true
    LEFT JOIN 
    UNNEST(JSON_QUERY_ARRAY(i.Ipv6Ranges)) AS ip6_ranges ON true
    where {{ partition_filter() }}
{% endmacro %}
