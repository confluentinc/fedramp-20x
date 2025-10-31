{% macro verify_default_security_group_unused(framework, check_id) %}
  {{ return(adapter.dispatch('verify_default_security_group_unused')(framework, check_id)) }}
{% endmacro %}

{% macro default__verify_default_security_group_unused(framework, check_id) %}{% endmacro %}

{% macro bigquery__verify_default_security_group_unused(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Verify default AWS Security Group is not used' as title,
    aws_ec2_security_groups.arn as identifier,
    null as metadata,
    case when resources.security_group_id is not null
             then 'fail'
         else 'pass'
        end as status,
    aws_ec2_security_groups.tags
from {{ full_table_name("aws_ec2_security_groups") }}
    left join (
  select security_group_id from {{ ref('aws_security_group_inventory') }}
  group by security_group_id
) resources
  on aws_ec2_security_groups.group_id = resources.security_group_id
where {{ partition_filter() }}
  and group_name = 'default'
    {% endmacro %}
