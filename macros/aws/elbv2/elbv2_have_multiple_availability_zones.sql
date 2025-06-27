{% macro elbv2_have_multiple_availability_zones(framework, check_id) %}
  {{ return(adapter.dispatch('elbv2_have_multiple_availability_zones')(framework, check_id)) }}
{% endmacro %}

{% macro default__elbv2_have_multiple_availability_zones(framework, check_id) %}{% endmacro %}

{% macro bigquery__elbv2_have_multiple_availability_zones(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'Application, Network and Gateway Load Balancers should span multiple Availability Zones' as title,
    account_id,
    arn as resource_id,
    case
        WHEN ARRAY_LENGTH(JSON_QUERY_ARRAY(availability_zones)) > 1 THEN 'pass'
        ELSE 'fail'
    END as status
FROM
    {{ full_table_name("aws_elbv2_load_balancers") }}
where {{ partition_filter() }}
{% endmacro %}
