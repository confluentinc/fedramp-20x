{% macro waf_web_acl_logging_should_be_enabled(framework, check_id) %}
  {{ return(adapter.dispatch('waf_web_acl_logging_should_be_enabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__waf_web_acl_logging_should_be_enabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__waf_web_acl_logging_should_be_enabled(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'AWS WAF Classic global web ACL logging should be enabled' as title,
    account_id,
    arn as resource_id,
    case when
        logging_configuration is null or JSON_VALUE(logging_configuration) = '{}'
    then 'fail' else 'pass' end as status
from {{ full_table_name("aws_waf_web_acls") }}
where {{ partition_filter("aws_waf_web_acls") }}
{% endmacro %}
