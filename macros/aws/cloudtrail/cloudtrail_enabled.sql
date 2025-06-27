{% macro cloudtrail_enabled(framework, check_id) %}
  {{ return(adapter.dispatch('cloudtrail_enabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__cloudtrail_enabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__cloudtrail_enabled(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'At least one CloudTrail trail should be enabled' as title,
    account_id,
    account_id as resource_id,
    CASE 
        WHEN COUNT(*) > 0 THEN 'Pass'
        ELSE 'Fail'
    END AS status
FROM {{ full_table_name("aws_cloudtrail_trails") }}
WHERE CAST(JSON_VALUE(status.IsLogging) AS STRING) = 'true'
AND {{ partition_filter() }}
GROUP by account_id
{% endmacro %}
