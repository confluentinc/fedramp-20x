{% macro default_root_object_configured(framework, check_id) %}
  {{ return(adapter.dispatch('default_root_object_configured')(framework, check_id)) }}
{% endmacro %}

{% macro default__default_root_object_configured(framework, check_id) %}{% endmacro %}

{% macro bigquery__default_root_object_configured(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'CloudFront distributions should have a default root object configured' as title,
    account_id,
    arn as resource_id,
    CASE
        WHEN CAST(JSON_VALUE(distribution_config.DefaultRootObject) AS STRING) = '' THEN 'fail'
        ELSE 'pass'
    END AS status
FROM {{ full_table_name("aws_cloudfront_distributions") }}
WHERE {{ partition_filter() }}
{% endmacro %}
