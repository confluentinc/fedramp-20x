{% macro no_broad_public_ingress_on_port_22(framework, check_id) %}
  {{ return(adapter.dispatch('no_broad_public_ingress_on_port_22')(framework, check_id)) }}
{% endmacro %}

{% macro default__no_broad_public_ingress_on_port_22(framework, check_id) %}{% endmacro %}

{% macro bigquery__no_broad_public_ingress_on_port_22(framework, check_id) %}
select
  '{{framework}}' as framework,
  '{{check_id}}' as check_id,
  'Ensure no security groups allow ingress from 0.0.0.0/0 to port 22 (Scored)' as title,
  account_id,
  arn,
  case when
      (ip = '0.0.0.0/0' or ip = '::/0')
      and (
          (from_port is null and to_port is null) -- all ports
          or 22 between from_port and to_port)
      then 'fail'
      else 'pass'
  end
from {{ ref('aws_compliance__security_group_ingress_rules') }}
{% endmacro %}
