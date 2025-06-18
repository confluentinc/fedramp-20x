{% macro secrets_should_not_be_in_environment_variables(framework, check_id) %}
  {{ return(adapter.dispatch('secrets_should_not_be_in_environment_variables')(framework, check_id)) }}
{% endmacro %}

{% macro default__secrets_should_not_be_in_environment_variables(framework, check_id) %}{% endmacro %}

{% macro bigquery__secrets_should_not_be_in_environment_variables(framework, check_id) %}
with flat_containers AS (
SELECT 
    t.arn,
    t.account_id,
    CASE
        WHEN
          CAST(JSON_VALUE(f.environment) AS STRING) LIKE '%AWS_ACCESS_KEY_ID%' 
          OR
          CAST(JSON_VALUE(f.environment) AS STRING) LIKE '%AWS_SECRET_ACCESS_KEY%'
          OR
          CAST(JSON_VALUE(f.environment) AS STRING) LIKE '%ECS_ENGINE_AUTH_DATA%'
        THEN 1
        ELSE 0
    END as status
FROM 
    {{ full_table_name("aws_ecs_task_definitions") }}
 t,
 UNNEST(JSON_QUERY_ARRAY(container_definitions)) AS f
WHERE 
    t.status = 'ACTIVE'
and {{ partition_filter("t") }}
)
    
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'Secrets should not be passed as container environment variables' as title,
    account_id,
    arn as resource_id,
    CASE
        WHEN max(status) OVER (PARTITION BY arn) = 1 THEN 'fail'
        ELSE 'pass'
    END as status
from
    flat_containers
{% endmacro %}
