{% macro neptune_cluster_cloudwatch_log_export_enabled(framework, check_id) %}
  {{ return(adapter.dispatch('neptune_cluster_cloudwatch_log_export_enabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__neptune_cluster_cloudwatch_log_export_enabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__neptune_cluster_cloudwatch_log_export_enabled(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'Neptune DB clusters should publish audit logs to CloudWatch Logs' as title,
    account_id,
    arn as resource_id,
    case when
        'audit' IN UNNEST(ENABLED_CLOUDWATCH_LOGS_EXPORTS)
        then 'pass'
        else 'fail'
    end as status
from 
  {{ full_table_name("aws_neptune_clusters") }}
where {{ partition_filter() }}
{% endmacro %}
