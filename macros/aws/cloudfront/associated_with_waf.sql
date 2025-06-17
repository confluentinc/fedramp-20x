{% macro associated_with_waf(framework, check_id) %}
  {{ return(adapter.dispatch('associated_with_waf')(framework, check_id)) }}
{% endmacro %}

{% macro default__associated_with_waf(framework, check_id) %}{% endmacro %}

{% macro bigquery__associated_with_waf(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'API Gateway should be associated with an AWS WAF web ACL' as title,
    account_id,
    arn as resource_id,
    case
        when JSON_VALUE(distribution_config.WebACLId) = '' then 'fail'
        else 'pass'
    end as status
from {{ full_table_name("aws_cloudfront_distributions") }}
where {{ partition_filter() }}
{% endmacro %}
