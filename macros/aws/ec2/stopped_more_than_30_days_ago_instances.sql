{% macro stopped_more_than_30_days_ago_instances(framework, check_id) %}
  {{ return(adapter.dispatch('stopped_more_than_30_days_ago_instances')(framework, check_id)) }}
{% endmacro %}

{% macro default__stopped_more_than_30_days_ago_instances(framework, check_id) %}{% endmacro %}

{% macro bigquery__stopped_more_than_30_days_ago_instances(framework, check_id) %}
select
  '{{framework}}' As framework,
  '{{check_id}}' As check_id,
  'Stopped EC2 instances should be removed after a specified time period' as title,
  account_id,
  instance_id as resource_id,
  case when
      JSON_VALUE(state.Name) = 'stopped'
      and DATETIME_DIFF(CURRENT_DATETIME(), DATETIME(state_transition_reason_time), DAY) > 30
      then 'fail'
      else 'pass'
  end AS status
FROM {{ full_table_name("aws_ec2_instances") }}
    where {{ partition_filter() }}
{% endmacro %}
