{% macro elasticsearch_domains_should_have_audit_logging_enabled(framework, check_id) %}
  {{ return(adapter.dispatch('elasticsearch_domains_should_have_audit_logging_enabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__elasticsearch_domains_should_have_audit_logging_enabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__elasticsearch_domains_should_have_audit_logging_enabled(framework, check_id) %}
select
  '{{framework}}' As framework,
  '{{check_id}}' As check_id,
  'Elasticsearch domains should have audit logging enabled' as title,
  account_id,
  arn as resource_id,
  case when
    CAST( JSON_VALUE(log_publishing_options.AUDIT_LOGS.Enabled) AS BOOL) is distinct from true
    or log_publishing_options.AUDIT_LOGS.CloudWatchLogsLogGroupArn is null
    then 'fail'
    else 'pass'
  end as status
from {{ full_table_name("aws_elasticsearch_domains") }}
where {{ partition_filter() }}
{% endmacro %}
