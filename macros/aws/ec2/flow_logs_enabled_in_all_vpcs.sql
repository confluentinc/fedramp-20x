{% macro flow_logs_enabled_in_all_vpcs(framework, check_id) %}
  {{ return(adapter.dispatch('flow_logs_enabled_in_all_vpcs')(framework, check_id)) }}
{% endmacro %}

{% macro default__flow_logs_enabled_in_all_vpcs(framework, check_id) %}{% endmacro %}

{% macro bigquery__flow_logs_enabled_in_all_vpcs(framework, check_id) %}
select
  DISTINCT
  '{{framework}}' as framework,
  '{{check_id}}' as check_id,
  'VPC flow logging should be enabled in all VPCs' as title,
  aws_ec2_vpcs.account_id,
  aws_ec2_vpcs.arn,
  case when
      aws_ec2_flow_logs.resource_id is null
      then 'fail'
      else 'pass'
  end as status
from {{ full_table_name("aws_ec2_vpcs") }}
left join {{ full_table_name("aws_ec2_flow_logs") }} on
        aws_ec2_vpcs.vpc_id = aws_ec2_flow_logs.resource_id
where {{ partition_filter("aws_ec2_vpcs") }}
{% endmacro %}
