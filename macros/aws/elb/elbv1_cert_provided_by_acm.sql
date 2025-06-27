{% macro elbv1_cert_provided_by_acm(framework, check_id) %}
  {{ return(adapter.dispatch('elbv1_cert_provided_by_acm')(framework, check_id)) }}
{% endmacro %}

{% macro default__elbv1_cert_provided_by_acm(framework, check_id) %}{% endmacro %}

{% macro bigquery__elbv1_cert_provided_by_acm(framework, check_id) %}
with listeners as (
  select
      lb.account_id as account_id,
      lb.arn as resource_id,
      JSON_VALUE(li.Listener.Protocol) as protocol,
      JSON_VALUE(li.Listener.SSLCertificateId) as ssl_certificate_id
  from
      {{ full_table_name("aws_elbv1_load_balancers") }} lb,
      UNNEST(JSON_QUERY_ARRAY(listener_descriptions)) AS li
  where {{ partition_filter("lb")}}
)

select
  '{{framework}}' As framework,
  '{{check_id}}' As check_id,
  'Classic Load Balancers with SSL/HTTPS listeners should use a certificate provided by AWS Certificate Manager' as title,
  listeners.account_id,
  listeners.resource_id,
  case when
    listeners.protocol = 'HTTPS' and aws_acm_certificates.arn is null
    then 'fail'
    else 'pass'
  end as status
from listeners
left join {{ full_table_name("aws_acm_certificates") }} on aws_acm_certificates.arn = listeners.ssl_certificate_id

{% endmacro %}
