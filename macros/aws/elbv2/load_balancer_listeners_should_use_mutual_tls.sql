{% macro load_balancer_listeners_should_use_mutual_tls(framework, check_id) %}
  {{ return(adapter.dispatch('load_balancer_listeners_should_use_mutual_tls')(framework, check_id)) }}
{% endmacro %}

{% macro default__load_balancer_listeners_should_use_mutual_tls(framework, check_id) %}{% endmacro %}

{% macro bigquery__load_balancer_listeners_should_use_mutual_tls(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Load balancer listeners should use mutual TLS authentication' as title,
    account_id,
    listener_arn as resource_id,
    case when
        protocol in ('HTTPS', 'TLS')
        and (mutual_authentication is null 
            or JSON_VALUE(mutual_authentication.Mode) = 'off'
            or JSON_VALUE(mutual_authentication.Mode) is null)
        then 'fail'
        else 'pass'
    end as status
from {{ full_table_name("aws_elbv2_listeners") }}
where {{ partition_filter() }}
    and protocol in ('HTTPS', 'TLS')
{% endmacro %}
