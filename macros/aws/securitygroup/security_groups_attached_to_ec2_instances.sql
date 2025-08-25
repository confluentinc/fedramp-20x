{% macro security_groups_attached_to_ec2_instances() %}
  {{ return(adapter.dispatch('security_groups_attached_to_ec2_instances')()) }}
{% endmacro %}

{% macro default__security_groups_attached_to_ec2_instances() %}{% endmacro %}

{% macro bigquery__security_groups_attached_to_ec2_instances() %}
select
    s.group_id as security_group_id,
    s.group_name as security_group_name,
    s.arn as security_group_arn,
    "aws_ec2_instances" as resource_type,
    i.arn as resource_arn,
    i.tags as tags
from {{ full_table_name("aws_ec2_instances") }} i,
UNNEST(JSON_EXTRACT_ARRAY(i.security_groups, '$')) AS security_group
LEFT JOIN {{ full_table_name("aws_ec2_security_groups") }} s
    ON JSON_VALUE(security_group, '$.GroupId') = s.group_id
    AND {{ partition_filter("s") }}
WHERE {{ partition_filter("i") }}
    {% endmacro %}
