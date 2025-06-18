{% macro vpcs_without_ec2_endpoint(framework, check_id) %}
  {{ return(adapter.dispatch('vpcs_without_ec2_endpoint')(framework, check_id)) }}
{% endmacro %}

{% macro default__vpcs_without_ec2_endpoint(framework, check_id) %}{% endmacro %}

{% macro bigquery__vpcs_without_ec2_endpoint(framework, check_id) %}
with endpoints as (
    select vpc_endpoint_id
    from {{ full_table_name("aws_ec2_vpc_endpoints") }}
    where vpc_endpoint_type = 'Interface'
        and service_name like CONCAT(
            'com.amazonaws.', region, '.ec2'
        )
        and {{ partition_filter("aws_ec2_vpc_endpoints") }}
)

select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'Amazon EC2 should be configured to use VPC endpoints that are created for the Amazon EC2 service' as title,
    account_id,
    aws_ec2_vpcs.arn as resource_id,
    case when
        endpoints.vpc_endpoint_id is null
        then 'fail'
        else 'pass'
    end as status
from {{ full_table_name("aws_ec2_vpcs") }}
left join endpoints
    on aws_ec2_vpcs.vpc_id = endpoints.vpc_endpoint_id
where {{ partition_filter("aws_ec2_vpcs") }}
{% endmacro %}
