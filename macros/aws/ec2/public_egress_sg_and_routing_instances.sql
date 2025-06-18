{% macro public_egress_sg_and_routing_instances(framework, check_id) %}
  {{ return(adapter.dispatch('public_egress_sg_and_routing_instances')(framework, check_id)) }}
{% endmacro %}

{% macro default__public_egress_sg_and_routing_instances(framework, check_id) %}{% endmacro %}

{% macro bigquery__public_egress_sg_and_routing_instances(framework, check_id) %}
-- Find all AWS instances that are in a subnet that includes a catchall route
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Find all ec2 instances that have unrestricted access to the internet with a wide open security group and routing' as title,
    account_id,
    instance_id as resource_id,
    'fail' as status -- TODO FIXME
from {{ full_table_name("aws_ec2_instances") }}
where subnet_id in
    --  Find all subnets that include a route table that inclues a catchall route
    (select JSON_VALUE(a.SubnetId)
        from {{ full_table_name("aws_ec2_route_tables") }} t, UNNEST(JSON_QUERY_ARRAY(t.associations)) AS a, UNNEST(JSON_QUERY_ARRAY(t.routes)) AS r
        --  Find all routes in any route table that contains a route to 0.0.0.0/0 or ::/0
        where JSON_VALUE(r.DestinationCidrBlock) = '0.0.0.0/0' OR JSON_VALUE(r.DestinationIpv6CidrBlock) = '::/0'
    )
    and instance_id in
    -- 	Find all instances that have egress rule that allows access to all ip addresses
    (select instance_id
        from {{ full_table_name("aws_ec2_instances") }}, UNNEST(JSON_QUERY_ARRAY(security_groups)) AS sg
        inner join {{ ref('aws_compliance__security_group_egress_rules') }} on id = JSON_VALUE(sg.GroupId)
        where (ip = '0.0.0.0/0' or ip6 = '::/0'))
and {{ partition_filter() }}
{% endmacro %}
