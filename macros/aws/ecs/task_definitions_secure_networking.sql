{% macro task_definitions_secure_networking(framework, check_id) %}
  {{ return(adapter.dispatch('task_definitions_secure_networking')(framework, check_id)) }}
{% endmacro %}

{% macro default__task_definitions_secure_networking(framework, check_id) %}{% endmacro %}

{% macro bigquery__task_definitions_secure_networking(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'Amazon ECS task definitions should have secure networking modes and user definitions' as title,
    account_id,
    arn as resource_id,
    case when
        network_mode = 'host'
        and CAST( JSON_VALUE(c.Privileged) AS BOOL) is distinct from true
        and (JSON_VALUE(c.User) = 'root' or c.User is null)
    then 'fail'
    else 'pass'
    end as status
from {{ full_table_name("aws_ecs_task_definitions") }},
UNNEST(JSON_QUERY_ARRAY(container_definitions)) AS c
where {{ partition_filter("aws_ecs_task_definitions") }}
{% endmacro %}
