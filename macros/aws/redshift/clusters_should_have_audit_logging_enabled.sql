{% macro clusters_should_have_audit_logging_enabled(framework, check_id) %}
  {{ return(adapter.dispatch('clusters_should_have_audit_logging_enabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__clusters_should_have_audit_logging_enabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__clusters_should_have_audit_logging_enabled(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Amazon Redshift clusters should have audit logging enabled' as title,
    account_id,
    arn as resource_id,
    case when
    logging_status.LoggingEnabled is null
    then 'fail' else 'pass' end as status
FROM {{ full_table_name("aws_redshift_clusters") }}
WHERE {{ partition_filter() }}
{% endmacro %}   
