{% macro rds_instances_have_outbound_access_restrictions(framework, check_id) %}
  {{ return(adapter.dispatch('rds_instances_have_outbound_access_restrictions')(framework, check_id)) }}
{% endmacro %}

{% macro default__rds_instances_have_outbound_access_restrictions(framework, check_id) %}{% endmacro %}

{% macro bigquery__rds_instances_have_outbound_access_restrictions(framework, check_id) %}
with instance_accesses as (
  select rds.arn as resource_arn, sgr.* from {{ full_table_name("aws_rds_instances") }} rds,
    unnest(json_extract_array(rds.vpc_security_groups)) as vpc_sg
    left join {{ ref("aws_compliance__security_group_egress_rules") }} sgr
      on JSON_VALUE(vpc_sg, "$.VpcSecurityGroupId") = sgr.id
  where {{ partition_filter("rds") }}
  and JSON_VALUE(vpc_sg, "$.Status") = 'active'
),
instances as (
    select * from {{ full_table_name("aws_rds_instances") }} rds
    where {{ partition_filter("rds") }}
)
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'RDS Instances should have restrictions on outbound access' as title,
    JSON_OBJECT() as metadata,
    arn AS identifier,
    case when exists
        -- We check for any security groups that allow broad access, and fail
        (select *
        from instance_accesses ia
        where ia.resource_arn = instances.arn
            and (ip = '0.0.0.0/0' or ip6 = '::/0')
            and (to_port is null or from_port is null)
        limit 1
    ) then 'fail' else 'pass'
    end as status,
    tags
from instances
{% endmacro %}
