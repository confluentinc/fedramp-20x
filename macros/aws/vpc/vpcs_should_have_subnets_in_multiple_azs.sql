{% macro vpcs_should_have_subnets_in_multiple_azs(framework, check_id) %}
  {{ return(adapter.dispatch('vpcs_should_have_subnets_in_multiple_azs')(framework, check_id)) }}
{% endmacro %}

{% macro default__vpcs_should_have_subnets_in_multiple_azs(framework, check_id) %}{% endmacro %}

{% macro bigquery__vpcs_should_have_subnets_in_multiple_azs(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'VPCs should have subnets in multiple availability zones' as title,
    vpc.arn as identifier,
    null as metadata,
    case when az_count > 1
         then 'pass'
         else 'fail'
    end as status,
    vpc.tags
from {{ full_table_name("aws_ec2_vpcs") }} vpc
join (
  select vpc_id, count(distinct availability_zone) as az_count
  from {{ full_table_name("aws_ec2_subnets") }}
  where {{ partition_filter() }}
  group by vpc_id, availability_zone
) as subnet_az_count
on vpc.vpc_id = subnet_az_count.vpc_id
-- Default VPCs aren't configured correctly, and we don't want to include them in this check.
-- Separate checks will verify that resources aren't using the default VPC
where is_default = false
and {{ partition_filter() }}
    {% endmacro %}
