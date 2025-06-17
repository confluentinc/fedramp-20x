{% macro instances_with_more_than_2_network_interfaces(framework, check_id) %}
  {{ return(adapter.dispatch('instances_with_more_than_2_network_interfaces')(framework, check_id)) }}
{% endmacro %}

{% macro default__instances_with_more_than_2_network_interfaces(framework, check_id) %}{% endmacro %}

{% macro bigquery__instances_with_more_than_2_network_interfaces(framework, check_id) %}
with data as (
    select account_id, instance_id, COUNT(JSON_VALUE(nics.Status)) as cnt
    from {{ full_table_name("aws_ec2_instances") }}, 
    UNNEST(JSON_QUERY_ARRAY(network_interfaces)) AS nics
    where {{ partition_filter("aws_ec2_instances") }}
    group by account_id, instance_id
)
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'EC2 instances should not use multiple ENIs' as title,
    account_id,
    instance_id as resource_id,
    case when cnt > 1 then 'fail' else 'pass' end as status
from data
{% endmacro %}

