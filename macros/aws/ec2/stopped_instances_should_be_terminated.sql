{% macro stopped_instances_should_be_terminated(framework, check_id) %}
  {{ return(adapter.dispatch('stopped_instances_should_be_terminated')(framework, check_id)) }}
{% endmacro %}

{% macro default__stopped_instances_should_be_terminated(framework, check_id) %}{% endmacro %}

{% macro bigquery__stopped_instances_should_be_terminated(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Long-stopped EC2 instances should be terminated' as title,
    instance_id as identifier,
    JSON_OBJECT() as metadata,
    case when
        JSON_VALUE(state.Name) IN ('stopped', 'stopping')
        and DATETIME_DIFF(CURRENT_DATETIME(), DATETIME(state_transition_reason_time), DAY) > 30
        then 'fail'
        else 'pass'
    end as status,
    tags
from {{ full_table_name("aws_ec2_instances") }}
where {{ partition_filter() }}
{% endmacro %}
