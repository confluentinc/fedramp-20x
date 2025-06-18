{% macro alb_should_have_acceptable_tls_policy(framework, check_id) %}
  {{ return(adapter.dispatch('alb_should_have_acceptable_tls_policy')(framework, check_id)) }}
{% endmacro %}

{% macro default__alb_should_have_acceptable_tls_policy(framework, check_id) %}{% endmacro %}

{% macro bigquery__alb_should_have_acceptable_tls_policy(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Application Load Balancers should have an acceptable TLS policy' as title,
    list.arn as identifier,
    null as metadata,
    case when ssl_policy = 'ELBSecurityPolicy-TLS13-1-2-FIPS-2023-04'
        then 'pass'
        else 'fail'
    end as status,
    lb.tags as tags
from {{ full_table_name("aws_elbv2_listeners") }} list
left join {{ full_table_name("aws_elbv2_load_balancers") }} lb
on list.load_balancer_arn = lb.load_balance_arn
and {{ partition_join("list", "lb") }}
WHERE {{ partition_filter("list") }}
{% endmacro %}