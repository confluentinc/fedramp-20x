{% macro s3_event_notifications_enabled(framework, check_id) %}
  {{ return(adapter.dispatch('s3_event_notifications_enabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__s3_event_notifications_enabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__s3_event_notifications_enabled(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'S3 buckets should have event notifications enabled' AS title,
    account_id,
    bucket_arn AS resource_id,    
    CASE WHEN
        (CAST(JSON_VALUE(EVENT_BRIDGE_CONFIGURATION) AS STRING) IS NULL OR ARRAY_LENGTH(JSON_QUERY_ARRAY(EVENT_BRIDGE_CONFIGURATION)) = 0)
        AND (CAST(JSON_VALUE(LAMBDA_FUNCTION_CONFIGURATIONS) AS STRING) IS NULL OR ARRAY_LENGTH(JSON_QUERY_ARRAY(LAMBDA_FUNCTION_CONFIGURATIONS)) = 0)
        AND (CAST(JSON_VALUE(QUEUE_CONFIGURATIONS) AS STRING) IS NULL OR ARRAY_LENGTH(JSON_QUERY_ARRAY(QUEUE_CONFIGURATIONS)) = 0)
        AND (CAST(JSON_VALUE(TOPIC_CONFIGURATIONS) AS STRING) IS NULL OR ARRAY_LENGTH(JSON_QUERY_ARRAY(TOPIC_CONFIGURATIONS)) = 0)
    THEN 'fail'
    ELSE 'pass'
    END AS status
FROM
    {{ full_table_name("aws_s3_bucket_notification_configurations") }}
where {{ partition_filter() }}
{% endmacro %}
