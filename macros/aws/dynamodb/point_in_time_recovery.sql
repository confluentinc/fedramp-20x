{% macro point_in_time_recovery(framework, check_id) %}
  {{ return(adapter.dispatch('point_in_time_recovery')(framework, check_id)) }}
{% endmacro %}

{% macro default__point_in_time_recovery(framework, check_id) %}{% endmacro %}

{% macro bigquery__point_in_time_recovery(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'DynamoDB tables should have point-in-time recovery enabled' as title,
    t.account_id,
    t.arn as resource_id,
  case when
    JSON_VALUE(b.point_in_time_recovery_description.PointInTimeRecoveryStatus) is distinct from 'ENABLED'
    then 'fail'
    else 'pass'
  end as status
FROM {{ full_table_name("aws_dynamodb_tables") }} t
  LEFT JOIN {{ full_table_name("aws_dynamodb_table_continuous_backups") }}
 b ON b.table_arn = t.arn
where {{ partition_filter("t") }}
 {% endmacro %}
