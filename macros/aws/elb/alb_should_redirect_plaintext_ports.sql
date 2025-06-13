{% macro alb_should_redirect_plaintext_ports(framework, check_id) %}
  {{ return(adapter.dispatch('alb_should_redirect_plaintext_ports')(framework, check_id)) }}
{% endmacro %}

{% macro default__alb_should_redirect_plaintext_ports(framework, check_id) %}{% endmacro %}

{% macro bigquery__alb_should_redirect_plaintext_ports(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Application Load Balancer should be configured to redirect all HTTP requests to HTTPS' as title,
    list.arn as identifier,
    null as metadata,
    case when
             protocol = 'HTTP' and (
                 JSON_VALUE(da.Type) != 'redirect' or JSON_VALUE(da.RedirectConfig.Protocol) != 'HTTPS')
             then 'fail'
         else 'pass'
        end as status,
    lb.tags as tags
from {{ full_table_name("aws_elbv2_listeners") }} list,
     UNNEST(JSON_QUERY_ARRAY(default_actions)) AS da
left join {{ full_table_name("aws_elbv2_load_balancers") }} lb using (load_balancer_arn)
WHERE TIMESTAMP_TRUNC(lb._cq_sync_time, DAY) = TIMESTAMP(CURRENT_DATE())
    {% endmacro %}