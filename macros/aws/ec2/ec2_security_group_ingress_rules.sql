{% macro ec2_security_group_ingress_rules() %}
  {{ return(adapter.dispatch('ec2_security_group_ingress_rules')()) }}
{% endmacro %}

{% macro default__ec2_security_group_ingress_rules() %}{% endmacro %}

{% macro bigquery__ec2_security_group_ingress_rules() %}
    WITH 
    ip_permissions as (
      select
      i as value,
      account_id,
        region,
        group_name,
        arn,
        group_id ,
        vpc_id, 
      from {{ full_table_name("aws_ec2_security_groups") }},
    UNNEST(JSON_QUERY_ARRAY(ip_permissions)) as i
    where {{ partition_filter() }}
    ),
    ip_ranges as (
    select
      ip_ranges as value          
    FROM ip_permissions,
    UNNEST(JSON_QUERY_ARRAY(value.IpRanges)) as ip_ranges
      ),
    ip6_ranges as (
    select
      ip6_ranges as value          
    FROM ip_permissions,
    UNNEST(JSON_QUERY_ARRAY(value.Ipv6Ranges)) as ip6_ranges
    )    
select
        account_id,
        region,
        group_name,
        arn,
        group_id as id,
        vpc_id,
        CAST(JSON_VALUE(i.value.FromPort) AS INT64) AS from_port,
        CAST(JSON_VALUE(i.value.ToPort) AS INT64) AS to_port,
        JSON_VALUE(i.value.IpProtocol) AS ip_protocol,
        JSON_VALUE(ip_ranges.value.CidrIp) AS ip,
        JSON_VALUE(ip6_ranges.value.CidrIpv6) AS ip6
    from ip_permissions as i 
    LEFT JOIN ip_ranges ON TRUE
    LEFT JOIN ip6_ranges ON TRUE
{% endmacro %}
