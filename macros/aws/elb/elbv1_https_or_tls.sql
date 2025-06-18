{% macro elbv1_https_or_tls(framework, check_id) %}
  {{ return(adapter.dispatch('elbv1_https_or_tls')(framework, check_id)) }}
{% endmacro %}

{% macro default__elbv1_https_or_tls(framework, check_id) %}{% endmacro %}

{% macro bigquery__elbv1_https_or_tls(framework, check_id) %}
select
  '{{framework}}' As framework,
  '{{check_id}}' As check_id,
  'Classic Load Balancer listeners should be configured with HTTPS or TLS termination' as title,
  lb.account_id,
  lb.arn as resource_id,
  case when
    JSON_VALUE(li.Listener.Protocol) not in ('HTTPS', 'SSL')
    then 'fail'
    else 'pass'
  end as status
from {{ full_table_name("aws_elbv1_load_balancers") }} lb,
    UNNEST(JSON_QUERY_ARRAY(listener_descriptions)) AS li
where {{ partition_filter("lb") }}
{% endmacro %}
