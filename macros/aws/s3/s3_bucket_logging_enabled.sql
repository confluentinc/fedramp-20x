{% macro s3_bucket_logging_enabled(framework, check_id) %}
  {{ return(adapter.dispatch('s3_bucket_logging_enabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__s3_bucket_logging_enabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__s3_bucket_logging_enabled(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'S3 bucket server access logging should be enabled' AS title,
    b.account_id,
    b.arn AS resource_id,
    CASE
        when bl.logging_enabled.TargetBucket IS NOT NULL
        THEN 'pass' ELSE 'fail'
    END AS status
FROM
    {{ full_table_name("aws_s3_buckets") }} as b
LEFT JOIN
    {{ full_table_name("aws_s3_bucket_loggings") }} as bl on bl.bucket_arn = b.arn
WHERE {{ partition_filter("b") }}
{% endmacro %}
