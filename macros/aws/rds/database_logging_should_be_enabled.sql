{% macro database_logging_should_be_enabled(framework, check_id) %}
  {{ return(adapter.dispatch('database_logging_should_be_enabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__database_logging_should_be_enabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__database_logging_should_be_enabled(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Database logging should be enabled' as title,
    account_id,
    arn AS resource_id,
    case when
                 enabled_cloudwatch_logs_exports is null
                 or (engine in ('aurora', 'aurora-mysql', 'mariadb', 'mysql')
                 and not (
                  'audit' IN UNNEST(enabled_cloudwatch_logs_exports)
                  and
                  'error' IN UNNEST(enabled_cloudwatch_logs_exports)
                  and
                  'general' IN UNNEST(enabled_cloudwatch_logs_exports)
                  and 
                  'slowquery' IN UNNEST(enabled_cloudwatch_logs_exports)
                 )
                     )
                or (engine like '%postgres%'
                 and not 
                 (
                  'postgresql' IN UNNEST(enabled_cloudwatch_logs_exports)
                  and
                  'upgrade' IN UNNEST(enabled_cloudwatch_logs_exports)
                 )
                )
                 or (engine like '%oracle%'
                 and not 
                (
                  'alert' IN UNNEST(enabled_cloudwatch_logs_exports)
                  and
                  'audit' IN UNNEST(enabled_cloudwatch_logs_exports)
                  and
                  'trace' IN UNNEST(enabled_cloudwatch_logs_exports)
                  and
                  'listener' IN UNNEST(enabled_cloudwatch_logs_exports)
                )
                     )
                 or (engine like '%sqlserver%'
                 and not 
                 (
                  'error' IN UNNEST(enabled_cloudwatch_logs_exports)
                  and
                  'agent' IN UNNEST(enabled_cloudwatch_logs_exports)
                 )
                 )
      then 'fail' else 'pass' end as status
from {{ full_table_name("aws_rds_instances") }}
WHERE {{ partition_filter() }}
{% endmacro %}   
