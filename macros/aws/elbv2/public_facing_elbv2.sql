{% macro public_facing_elbv2() %}
  {{ return(adapter.dispatch('public_facing_elbv2')()) }}
{% endmacro %}

{% macro default__public_facing_elbv2() %}{% endmacro %}

{% macro bigquery__public_facing_elbv2() %}
SELECT
    'ALBs that are internet facing' as title,
    account_id,
    arn AS resource_id,
    'aws_elbv2_load_balancers' as resource_type,
    'alb_public_facing' as reachability_type,
    dns_name as endpoint,
    'dns_name' as endpoint_type
FROM
    {{ full_table_name("aws_elbv2_load_balancers") }}
WHERE {{ partition_filter() }}
  AND scheme = 'internet-facing'
    {% endmacro %}
