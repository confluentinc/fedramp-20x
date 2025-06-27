{% macro lambda_vpc_multi_az_check(framework, check_id) %}
  {{ return(adapter.dispatch('lambda_vpc_multi_az_check')(framework, check_id)) }}
{% endmacro %}

{% macro default__lambda_vpc_multi_az_check(framework, check_id) %}{% endmacro %}

{% macro bigquery__lambda_vpc_multi_az_check(framework, check_id) %}
select
    'foundational_security' As framework,
    'lambda.5' As check_id,
  'VPC Lambda functions should operate in more than one Availability Zone' AS title,
    l.account_id, 
    l.arn AS resource_id,
    CASE WHEN
    count (distinct s.availability_zone_id) > 1 THEN 'pass'
    ELSE 'fail'
    end as status
FROM
    {{ full_table_name("aws_lambda_functions") }} as l,
    UNNEST(JSON_QUERY_ARRAY(configuration.VpcConfig.SubnetIds)) AS a
LEFT JOIN
    {{ full_table_name("aws_ec2_subnets") }} s
ON
    JSON_VALUE(a.value) = s.subnet_id
where {{ partition_filter("l") }}
group by l.arn, l.account_id
{% endmacro %}
