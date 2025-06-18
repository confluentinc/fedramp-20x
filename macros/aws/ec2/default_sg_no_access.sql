{% macro default_sg_no_access(framework, check_id) %}
  {{ return(adapter.dispatch('default_sg_no_access')(framework, check_id)) }}
{% endmacro %}

{% macro default__default_sg_no_access(framework, check_id) %}{% endmacro %}

{% macro bigquery__default_sg_no_access(framework, check_id) %}
select
  '{{framework}}' as framework,
  '{{check_id}}' as check_id,
  'The VPC default security group should not allow inbound and outbound traffic' as title,
  account_id,
  arn as resource_id,
  CASE
      WHEN (
        ARRAY_LENGTH(JSON_EXTRACT_ARRAY(ip_permissions)) = 0
          OR (
          ARRAY_LENGTH(JSON_EXTRACT_ARRAY(ip_permissions)) = 1
            AND JSON_EXTRACT_SCALAR(JSON_EXTRACT_ARRAY(ip_permissions)[SAFE_OFFSET(0)], '$.FromPort') IS NULL
            AND JSON_EXTRACT_SCALAR(JSON_EXTRACT_ARRAY(ip_permissions)[SAFE_OFFSET(0)], '$.ToPort') IS NULL
            AND JSON_EXTRACT_SCALAR(JSON_EXTRACT_ARRAY(ip_permissions)[SAFE_OFFSET(0)], '$.IpProtocol') = '-1'
            AND ARRAY_LENGTH(JSON_EXTRACT_ARRAY(JSON_EXTRACT_ARRAY(ip_permissions)[SAFE_OFFSET(0)], '$.IpRanges')) = 0
            AND ARRAY_LENGTH(JSON_EXTRACT_ARRAY(JSON_EXTRACT_ARRAY(ip_permissions)[SAFE_OFFSET(0)], '$.Ipv6Ranges')) = 0
            AND ARRAY_LENGTH(JSON_EXTRACT_ARRAY(JSON_EXTRACT_ARRAY(ip_permissions)[SAFE_OFFSET(0)], '$.PrefixListIds')) = 0
            AND ARRAY_LENGTH(JSON_EXTRACT_ARRAY(JSON_EXTRACT_ARRAY(ip_permissions)[SAFE_OFFSET(0)], '$.UserIdGroupPairs')) = 1
            AND JSON_EXTRACT_SCALAR(JSON_EXTRACT_ARRAY(JSON_EXTRACT_ARRAY(ip_permissions)[SAFE_OFFSET(0)], '$.UserIdGroupPairs')[SAFE_OFFSET(0)], '$.GroupName') IS NULL
          )
      ) AND (
        ARRAY_LENGTH(JSON_EXTRACT_ARRAY(ip_permissions_egress)) = 0
          OR (
          ARRAY_LENGTH(JSON_EXTRACT_ARRAY(ip_permissions_egress)) = 1
            AND JSON_EXTRACT_SCALAR(JSON_EXTRACT_ARRAY(ip_permissions_egress)[SAFE_OFFSET(0)], '$.FromPort') IS NULL
            AND JSON_EXTRACT_SCALAR(JSON_EXTRACT_ARRAY(ip_permissions_egress)[SAFE_OFFSET(0)], '$.ToPort') IS NULL
            AND JSON_EXTRACT_SCALAR(JSON_EXTRACT_ARRAY(ip_permissions_egress)[SAFE_OFFSET(0)], '$.IpProtocol') = '-1'
            AND ARRAY_LENGTH(JSON_EXTRACT_ARRAY(JSON_EXTRACT_ARRAY(ip_permissions_egress)[SAFE_OFFSET(0)], '$.IpRanges')) = 1
            AND JSON_EXTRACT_SCALAR(JSON_EXTRACT_ARRAY(JSON_EXTRACT_ARRAY(ip_permissions_egress)[SAFE_OFFSET(0)], '$.IpRanges')[SAFE_OFFSET(0)], '$.CidrIp') = '0.0.0.0/0'
            AND JSON_EXTRACT_SCALAR(JSON_EXTRACT_ARRAY(JSON_EXTRACT_ARRAY(ip_permissions_egress)[SAFE_OFFSET(0)], '$.IpRanges')[SAFE_OFFSET(0)], '$.Description') IS NULL
            AND ARRAY_LENGTH(JSON_EXTRACT_ARRAY(JSON_EXTRACT_ARRAY(ip_permissions_egress)[SAFE_OFFSET(0)], '$.Ipv6Ranges')) = 0
            AND ARRAY_LENGTH(JSON_EXTRACT_ARRAY(JSON_EXTRACT_ARRAY(ip_permissions_egress)[SAFE_OFFSET(0)], '$.PrefixListIds')) = 0
            AND ARRAY_LENGTH(JSON_EXTRACT_ARRAY(JSON_EXTRACT_ARRAY(ip_permissions_egress)[SAFE_OFFSET(0)], '$.UserIdGroupPairs')) = 0
          )
        )
      THEN 'pass'
    ELSE 'fail'
  END AS status
from
    {{ full_table_name("aws_ec2_security_groups") }}
WHERE
    group_name = 'default'
    AND {{ partition_filter() }}
{% endmacro %}
