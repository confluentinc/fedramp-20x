{% macro access_logs_enabled(framework, check_id) %}
  {{ return(adapter.dispatch('access_logs_enabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__access_logs_enabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__access_logs_enabled(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'CloudFront distributions should have logging enabled' as title,
    account_id,
    arn as resource_id,
    case
        when CAST( JSON_VALUE(distribution_config.Logging.Enabled) AS BOOL)is distinct from true then 'fail'
        else 'pass'
    end as status
from {{ full_table_name("aws_cloudfront_distributions") }}
where {{ partition_filter() }}
{% endmacro %}
