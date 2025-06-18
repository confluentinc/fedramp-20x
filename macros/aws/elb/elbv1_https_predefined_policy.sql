{% macro elbv1_https_predefined_policy(framework, check_id) %}
  {{ return(adapter.dispatch('elbv1_https_predefined_policy')(framework, check_id)) }}
{% endmacro %}

{% macro default__elbv1_https_predefined_policy(framework, check_id) %}{% endmacro %}

{% macro bigquery__elbv1_https_predefined_policy(framework, check_id) %}
select
  '{{framework}}' As framework,
  '{{check_id}}' As check_id,
  'Classic Load Balancers with HTTPS/SSL listeners should use a predefined security policy that has strong configuration' as title,
  lb.account_id,
  lb.arn as resource_id,
  case when
    JSON_VALUE(li.Listener.Protocol) in ('HTTPS', 'SSL') 
    and 'ELBSecurityPolicy-TLS-1-2-2017-01' NOT IN UNNEST(JSON_EXTRACT_STRING_ARRAY(po.OtherPolicies))
    then 'fail'
    else 'pass'
  end as status
from {{ full_table_name("aws_elbv1_load_balancers") }}
 lb,
  UNNEST(JSON_QUERY_ARRAY(listener_descriptions)) AS li,
  UNNEST(JSON_QUERY_ARRAY(policies)) AS po
where {{ partition_filter("lb") }}
{% endmacro %}
