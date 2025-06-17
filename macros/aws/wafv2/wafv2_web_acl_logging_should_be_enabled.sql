{% macro wafv2_web_acl_logging_should_be_enabled(framework, check_id) %}
  {{ return(adapter.dispatch('wafv2_web_acl_logging_should_be_enabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__wafv2_web_acl_logging_should_be_enabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__wafv2_web_acl_logging_should_be_enabled(framework, check_id) %}
(
-- WAF Classic
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'AWS WAF Classic global web ACL logging should be enabled' as title,
    account_id,
    arn as resource_id,
    case when
        logging_configuration is null or JSON_VALUE(logging_configuration) = '{}'
    then 'fail' else 'pass' end as status
from {{ full_table_name("aws_waf_web_acls") }}
where {{ partition_filter() }}
)
union all
(
-- WAF V2
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'AWS WAF Classic global web ACL logging should be enabled' as title,
    account_id,
    arn as resource_id,
    case when
        logging_configuration is null or JSON_VALUE(logging_configuration) = '{}'
    then 'fail' else 'pass' end as status
from {{ full_table_name("aws_wafv2_web_acls") }}
where {{ partition_filter() }}
)
{% endmacro %}
