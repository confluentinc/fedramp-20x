{% macro load_balancers_should_enforce_https_only(framework, check_id) %}
  {{ return(adapter.dispatch('load_balancers_should_enforce_https_only')(framework, check_id)) }}
{% endmacro %}

{% macro default__load_balancers_should_enforce_https_only(framework, check_id) %}{% endmacro %}

{% macro bigquery__load_balancers_should_enforce_https_only(framework, check_id) %}
with http_listeners as (
    select 
        load_balancer_arn,
        count(*) as http_count
    from {{ full_table_name("aws_elbv2_listeners") }}
    where {{ partition_filter() }}
        and protocol in ('HTTP', 'TCP')
    group by load_balancer_arn
),
https_listeners as (
    select 
        load_balancer_arn,
        count(*) as https_count
    from {{ full_table_name("aws_elbv2_listeners") }}
    where {{ partition_filter() }}
        and protocol in ('HTTPS', 'TLS')
    group by load_balancer_arn
)
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Load balancers should enforce HTTPS-only communications' as title,
    lb.account_id,
    lb.load_balancer_name as resource_id,
    case when
        coalesce(http.http_count, 0) > 0
        and coalesce(https.https_count, 0) = 0
        then 'fail'
        else 'pass'
    end as status
from {{ full_table_name("aws_elbv2_load_balancers") }} lb
left join http_listeners http on lb.load_balancer_arn = http.load_balancer_arn
left join https_listeners https on lb.load_balancer_arn = https.load_balancer_arn
where {{ partition_filter("lb") }}
{% endmacro %}
