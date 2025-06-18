{% macro clusters_should_use_container_insights(framework, check_id) %}
  {{ return(adapter.dispatch('clusters_should_use_container_insights')(framework, check_id)) }}
{% endmacro %}

{% macro default__clusters_should_use_container_insights(framework, check_id) %}{% endmacro %}

{% macro bigquery__clusters_should_use_container_insights(framework, check_id) %}
with settings as (
SELECT DISTINCT
  arn
FROM
  {{ full_table_name("aws_ecs_clusters") }} c,
  UNNEST(JSON_QUERY_ARRAY(settings)) AS f
WHERE
    JSON_VALUE(f.Name) = 'containerInsights'
    AND
    JSON_VALUE(f.Value) <> 'enabled'
    AND {{ partition_filter("c") }}
  )
SELECT 
  '{{framework}}' As framework,
  '{{check_id}}' As check_id,
  'ECS clusters should use Container Insights' as title,
  c.account_id,
  c.arn as resource_id,
  CASE
    WHEN s.arn is not null THEN 'fail'
    ELSE 'pass'
    END as status
FROM
  {{ full_table_name("aws_ecs_clusters") }} c
LEFT JOIN
    settings s ON c.arn = s.arn
WHERE {{ partition_filter("c") }}

{% endmacro %}
