{% macro alb_security_groups_should_restrict_to_limited_ports(framework, check_id) %}
  {{ return(adapter.dispatch('alb_security_groups_should_restrict_to_limited_ports')(framework, check_id)) }}
{% endmacro %}

{% macro default__alb_security_groups_should_restrict_to_limited_ports(framework, check_id) %}{% endmacro %}

{% macro bigquery__alb_security_groups_should_restrict_to_limited_ports(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'Public ALBs should restrict traffic to defined ports' as title,
    arn as identifier,
    JSON_OBJECT('security_group', ingress.id) as metadata,
    case when ingress.id is not null
        then 'fail'
        else 'pass'
    end as status,
    tags
from {{ full_table_name("aws_elbv2_load_balancers") }}
left join UNNEST(security_groups) AS security_group
left join (
  select id from {{ ref('aws_compliance__security_group_ingress_rules') }}
  where (ip = '0.0.0.0/0' or ip = '::/0')
  and (from_port IS null or to_port IS null)
  group by id limit 1
) ingress on ingress.id = security_group
where {{ partition_filter() }}
    {% endmacro %}