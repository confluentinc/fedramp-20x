{% macro security_groups_not_associated(framework, check_id) %}
  {{ return(adapter.dispatch('security_groups_not_associated')(framework, check_id)) }}
{% endmacro %}

{% macro default__security_groups_not_associated(framework, check_id) %}{% endmacro %}

{% macro bigquery__security_groups_not_associated(framework, check_id) %}
WITH used_security_groups AS (
    -- Security groups associated with EC2 instances
    SELECT CAST(JSON_VALUE(sg.GroupId) AS STRING) as security_group_id
      FROM {{ full_table_name("aws_ec2_instances") }},
      UNNEST(JSON_QUERY_ARRAY(security_groups)) AS sg
      WHERE {{ partition_filter("aws_ec2_instances") }}
    UNION ALL
    -- Security groups associated with network interfaces
      SELECT CAST(JSON_VALUE(sg.GroupId) AS STRING) as security_group_id
      FROM {{ full_table_name("aws_ec2_network_interfaces") }},
      UNNEST(JSON_QUERY_ARRAY(`groups`)) AS sg
      WHERE {{ partition_filter("aws_ec2_network_interfaces") }}
)
SELECT 
  '{{framework}}' As framework,
  '{{check_id}}' As check_id,
  'Unused Amazon EC2 security groups should be removed' as title,
   account_id,
   arn as resource_id,
CASE
when group_id IN (SELECT DISTINCT security_group_id FROM used_security_groups) THEN 'pass'
ELSE 'fail'
END as status
FROM {{ full_table_name("aws_ec2_security_groups") }}
WHERE {{ partition_filter("aws_ec2_security_groups") }}
{% endmacro %}
