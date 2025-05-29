{% macro elb_should_redirect_http_to_https(framework, check_id) %}
  {{ return(adapter.dispatch('elb_should_redirect_http_to_https')(framework, check_id)) }}
{% endmacro %}

{% macro default__elb_should_redirect_http_to_https(framework, check_id) %}{% endmacro %}

{% macro bigquery__elb_should_redirect_http_to_https(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Application Load Balancer should be configured to redirect all HTTP requests to HTTPS' as title,
    arn as identifier,
    null as metadata,
    case when
             protocol = 'HTTP' and (
                 JSON_VALUE(da.Type) != 'redirect' or JSON_VALUE(da.RedirectConfig.Protocol) != 'HTTPS')
             then 'fail'
         else 'pass'
        end as status
from {{ full_table_name("aws_elbv2_listeners") }},
     UNNEST(JSON_QUERY_ARRAY(default_actions)) AS da
    {% endmacro %}