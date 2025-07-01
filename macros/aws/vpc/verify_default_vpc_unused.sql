{% macro verify_default_vpc_unused(framework, check_id) %}
  {{ return(adapter.dispatch('verify_default_vpc_unused')(framework, check_id)) }}
{% endmacro %}

{% macro default__verify_default_vpc_unused(framework, check_id) %}{% endmacro %}

{% macro bigquery__verify_default_vpc_unused(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Verify default AWS VPC is not used' as title,
    aws_ec2_vpcs.arn as identifier,
    null as metadata,
    case when resources.vpc_id is not null
        then 'fail'
        else 'pass'
    end as status,
    aws_ec2_vpcs.tags
from {{ full_table_name("aws_ec2_vpcs") }}
    left join (
  select vpc_id from {{ ref('aws_vpc_inventory') }}
  group by vpc_id
) resources
using (vpc_id)
where {{ partition_filter() }}
and is_default = true
    {% endmacro %}
