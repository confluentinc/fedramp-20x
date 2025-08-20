{% macro security_groups_attached_to_elbv2_load_balancers() %}
  {{ return(adapter.dispatch('security_groups_attached_to_elbv2_load_balancers')()) }}
{% endmacro %}

{% macro default__security_groups_attached_to_elbv2_load_balancers() %}{% endmacro %}

{% macro bigquery__security_groups_attached_to_elbv2_load_balancers() %}
select
    s.group_id as security_group_id,
    s.group_name as security_group_name,
    s.arn as security_group_arn,
    "aws_elbv2_load_balancers" as resource_type,
    lb.arn as resource_arn,
    lb.tags as tags
from {{ full_table_name("aws_elbv2_load_balancers") }} lb,
UNNEST(security_groups) AS security_group
LEFT JOIN {{ full_table_name("aws_ec2_security_groups") }} s
    ON security_group = s.group_id
    AND {{ partition_filter("s") }}
WHERE {{ partition_filter("lb") }}
    {% endmacro %}
