{% macro autoscaling_multiple_instance_types(framework, check_id) %}
  {{ return(adapter.dispatch('autoscaling_multiple_instance_types')(framework, check_id)) }}
{% endmacro %}

{% macro default__autoscaling_multiple_instance_types(framework, check_id) %}{% endmacro %}

{% macro bigquery__autoscaling_multiple_instance_types(framework, check_id) %}
select
  '{{framework}}' As framework,
  '{{check_id}}' As check_id,
  'Auto Scaling groups should use multiple instance types in multiple Availability Zones' AS title,
  aag.account_id,
  ditc.arn AS resource_id,
  ditc.status
FROM {{ full_table_name("aws_autoscaling_groups") }} as aag
JOIN (
  SELECT
    arn,
    CASE
      WHEN COUNT(DISTINCT JSON_VALUE(instance.InstanceType)) > 1 THEN 'pass'
      ELSE 'fail'
    END AS status
  FROM
    {{ full_table_name("aws_autoscaling_groups") }} AS aag,
    UNNEST(JSON_QUERY_ARRAY(aag.INSTANCES)) AS instance
    WHERE {{ partition_filter("aag") }}
  GROUP BY arn
) AS ditc ON aag.arn = ditc.arn
{% endmacro %}
