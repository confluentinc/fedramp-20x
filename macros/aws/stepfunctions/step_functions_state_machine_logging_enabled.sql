{% macro step_functions_state_machine_logging_enabled(framework, check_id) %}
  {{ return(adapter.dispatch('step_functions_state_machine_logging_enabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__step_functions_state_machine_logging_enabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__step_functions_state_machine_logging_enabled(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'Step Functions state machines should have logging turned on' as title,
    account_id,
    arn as resource_id,
    case when
     LOGGING_CONFIGURATION.Level is null or JSON_VALUE(LOGGING_CONFIGURATION.Level) = 'OFF' 
     or (JSON_VALUE(LOGGING_CONFIGURATION.Level) != 'OFF' and LOGGING_CONFIGURATION.destinations is null) then 'fail'
     else 'pass'
     end as status
FROM {{ full_table_name("aws_stepfunctions_state_machines") }}
WHERE {{ partition_filter() }}
{% endmacro %}
