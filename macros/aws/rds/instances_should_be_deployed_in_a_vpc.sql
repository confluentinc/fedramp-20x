{% macro instances_should_be_deployed_in_a_vpc(framework, check_id) %}
  {{ return(adapter.dispatch('instances_should_be_deployed_in_a_vpc')(framework, check_id)) }}
{% endmacro %}

{% macro default__instances_should_be_deployed_in_a_vpc(framework, check_id) %}{% endmacro %}

{% macro bigquery__instances_should_be_deployed_in_a_vpc(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'RDS instances should be deployed in a VPC' as title,
    account_id,
    arn AS resource_id,
    case when JSON_VALUE(db_subnet_group.VpcId) is null then 'fail' else 'pass' end as status
from {{ full_table_name("aws_rds_instances") }}
where {{ partition_filter() }}
{% endmacro %}
