{% macro vpc_flow_logs_should_be_enabled(framework, check_id) %}
  {{ return(adapter.dispatch('vpc_flow_logs_should_be_enabled')(framework, check_id)) }}
{% endmacro %}

{% macro bigquery__vpc_flow_logs_should_be_enabled(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'VPC flow logging should be enabled in all VPCs' as title,
    aws_ec2_vpcs.arn as identifier,
    null as metadata,
    case when
             aws_ec2_flow_logs.resource_id is null
             then 'fail'
         else 'pass'
        end
from {{ full_table_name("aws_ec2_vpcs") }}
    left join {{ full_table_name("aws_ec2_flow_logs") }} on
    aws_ec2_vpcs.vpc_id = aws_ec2_flow_logs.resource_id
{% endmacro %}