{% macro elb_should_be_multi_az(framework, check_id) %}
  {{ return(adapter.dispatch('elb_should_be_multi_az')(framework, check_id)) }}
{% endmacro %}

{% macro default__elb_should_be_multi_az(framework, check_id) %}{% endmacro %}

{% macro bigquery__elb_should_be_multi_az(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'Application, Network and Gateway Load Balancers should span multiple Availability Zones' as title,
    arn as identifier,
    null as metadata,
    case
        WHEN ARRAY_LENGTH(JSON_QUERY_ARRAY(availability_zones)) > 1 THEN 'pass'
        ELSE 'fail'
        END as status
FROM
    {{ full_table_name("aws_elbv2_load_balancers") }}
{% endmacro %}