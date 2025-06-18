{% macro integrated_with_cloudwatch_logs(framework, check_id) %}
  {{ return(adapter.dispatch('integrated_with_cloudwatch_logs')(framework, check_id)) }}
{% endmacro %}

{% macro default__integrated_with_cloudwatch_logs(framework, check_id) %}{% endmacro %}


{% macro bigquery__integrated_with_cloudwatch_logs(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'CloudTrail trails should be integrated with CloudWatch Logs' as title,
    account_id,
    arn as resource_id,
    case
        when cloud_watch_logs_log_group_arn is null
            OR CAST(JSON_VALUE(status.LatestCloudWatchLogsDeliveryTime) AS timestamp) < TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 1 DAY)
        then 'fail'
        else 'pass'
    end as status
from {{ full_table_name("aws_cloudtrail_trails") }}
where {{ partition_filter() }}
{% endmacro %}
