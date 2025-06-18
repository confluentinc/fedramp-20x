{% macro logs_encrypted(framework, check_id) %}
  {{ return(adapter.dispatch('logs_encrypted')(framework, check_id)) }}
{% endmacro %}

{% macro default__logs_encrypted(framework, check_id) %}{% endmacro %}

{% macro bigquery__logs_encrypted(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'CloudTrail should have encryption at rest enabled' as title,
    account_id,
    arn as resource_id,
    case
        when kms_key_id is NULL then 'fail'
        else 'pass'
    end as status
FROM {{ full_table_name("aws_cloudtrail_trails") }}
where {{ partition_filter() }}
{% endmacro %}
