{% macro security_groups_attached_to_rds_instances() %}
  {{ return(adapter.dispatch('security_groups_attached_to_rds_instances')()) }}
{% endmacro %}

{% macro default__security_groups_attached_to_rds_instances() %}{% endmacro %}

{% macro bigquery__security_groups_attached_to_rds_instances() %}
select
    s.group_id as security_group_id,
    s.group_name as security_group_name,
    s.arn as security_group_arn,
    "aws_rds_instances" as resource_type,
    r.db_instance_arn as resource_arn,
    r.tags as tags
from {{ full_table_name("aws_rds_instances") }} r,
UNNEST(JSON_EXTRACT_ARRAY(r.vpc_security_groups, '$')) AS security_group
LEFT JOIN {{ full_table_name("aws_ec2_security_groups") }} s
    ON JSON_VALUE(security_group, '$.VpcSecurityGroupId') = s.group_id
    AND {{ partition_filter("s") }}
WHERE {{ partition_filter("r") }}
    {% endmacro %}
