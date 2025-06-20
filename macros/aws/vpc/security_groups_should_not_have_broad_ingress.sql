{% macro security_groups_should_not_have_broad_ingress(framework, check_id) %}
  {{ return(adapter.dispatch('security_groups_should_not_have_broad_ingress')(framework, check_id)) }}
{% endmacro %}

{% macro default__security_groups_should_not_have_broad_ingress(framework, check_id) %}{% endmacro %}

{% macro bigquery__security_groups_should_not_have_broad_ingress(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Security groups should not allow 0.0.0.0/0 ingress' as title,
    arn as identifier,
    null as metadata,
    case when ingress.id is not null
        then 'fail'
        else 'pass'
    end as status,
    tags
from {{ full_table_name("aws_ec2_security_groups") }}
left join (
  select id from {{ ref('aws_compliance__security_group_ingress_rules') }}
  where (ip = '0.0.0.0/0' or ip = '::/0') group by id
) ingress
on ingress.id = aws_ec2_security_groups.group_id
where {{ partition_filter() }}
{% endmacro %}
