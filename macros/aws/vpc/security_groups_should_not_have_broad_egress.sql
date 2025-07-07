{% macro security_groups_should_not_have_broad_egress(framework, check_id) %}
  {{ return(adapter.dispatch('security_groups_should_not_have_broad_egress')(framework, check_id)) }}
{% endmacro %}

{% macro default__security_groups_should_not_have_broad_egress(framework, check_id) %}{% endmacro %}

{% macro bigquery__security_groups_should_not_have_broad_egress(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Security groups should not allow 0.0.0.0/0 egress' as title,
    sg.arn as identifier,
    JSON_OBJECT('vpc_id', vpc.vpc_id) as metadata,
    case when egress.id is not null
        then 'fail'
        else 'pass'
    end as status,
    sg.tags
from {{ full_table_name("aws_ec2_security_groups") }} as sg
left join (
  select id from {{ ref('aws_compliance__security_group_egress_rules') }}
  where (ip = '0.0.0.0/0' or ip = '::/0') group by id
) egress
on egress.id = sg.group_id
left join {{ full_table_name("aws_ec2_vpcs") }} as vpc on sg.vpc_id = vpc.vpc_id
    and {{ partition_join("sg", "vpc")}}
where {{ partition_filter("sg") }}
and vpc.is_default = false
{% endmacro %}
