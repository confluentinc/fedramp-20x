{% macro unused_load_balancers_should_be_removed(framework, check_id) %}
  {{ return(adapter.dispatch('unused_load_balancers_should_be_removed')(framework, check_id)) }}
{% endmacro %}

{% macro default__unused_load_balancers_should_be_removed(framework, check_id) %}{% endmacro %}

{% macro bigquery__unused_load_balancers_should_be_removed(framework, check_id) %}
with lb_with_targets as (
    select distinct lb_arn
    from (
        select unnest(load_balancer_arns) as lb_arn
        from {{ full_table_name("aws_elbv2_target_groups") }}
        where {{ partition_filter() }}
    )
)
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Load balancers should have associated target groups' as title,
    lb.arn as identifier,
    JSON_OBJECT() as metadata,
    case when
        JSON_VALUE(lb.state.Code) = 'active'
        and DATETIME_DIFF(CURRENT_DATETIME(), DATETIME(lb.created_time), DAY) > 30
        and targets.lb_arn is null
        then 'fail'
        else 'pass'
    end as status,
    lb.tags as tags
from {{ full_table_name("aws_elbv2_load_balancers") }} lb
left join lb_with_targets targets on lb.load_balancer_arn = targets.lb_arn
where {{ partition_filter("lb") }}
{% endmacro %}
