{% macro empty_target_groups_should_be_removed(framework, check_id) %}
  {{ return(adapter.dispatch('empty_target_groups_should_be_removed')(framework, check_id)) }}
{% endmacro %}

{% macro default__empty_target_groups_should_be_removed(framework, check_id) %}{% endmacro %}

{% macro bigquery__empty_target_groups_should_be_removed(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Target groups should be associated with load balancers' as title,
    arn as identifier,
    JSON_OBJECT() as metadata,
    case when
        array_length(load_balancer_arns) = 0
        or load_balancer_arns is null
        then 'fail'
        else 'pass'
    end as status,
    tags
from {{ full_table_name("aws_elbv2_target_groups") }}
where {{ partition_filter() }}
{% endmacro %}
