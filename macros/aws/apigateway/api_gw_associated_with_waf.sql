{% macro api_gw_associated_with_waf(framework, check_id) %}
  {{ return(adapter.dispatch('api_gw_associated_with_waf')(framework, check_id)) }}
{% endmacro %}

{% macro default__api_gw_associated_with_waf(framework, check_id) %}{% endmacro %}

{% macro bigquery__api_gw_associated_with_waf(framework, check_id) %}
SELECT 
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'API Gateway should be associated with a WAF ACL' as title,
    account_id, 
    arn as resource_id,
    CASE
        WHEN web_acl_arn is not null THEN 'pass'
        ELSE 'fail'
    END as status
FROM 
    {{ full_table_name("aws_apigateway_rest_api_stages") }}
where {{ partition_filter() }}
{% endmacro %}
