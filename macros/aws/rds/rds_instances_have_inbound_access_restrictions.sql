{% macro rds_instances_have_inbound_access_restrictions(framework, check_id) %}
  {{ return(adapter.dispatch('rds_db_instances_should_prohibit_public_access')(framework, check_id)) }}
{% endmacro %}

{% macro default__rds_instances_have_inbound_access_restrictions(framework, check_id) %}{% endmacro %}

{% macro bigquery__rds_instances_have_inbound_access_restrictions(framework, check_id) %}
-- this should show up?
with instance_accesses as (
  select * from {{ full_table_name("aws_rds_instances") }} rds
    left join unnest(json_extract_array(rds.vpc_security_groups)) as vpc_sg
    left join {{ ref("aws_compliance__security_group_ingress_rules") }} sgr
      on vpc_sg.VpcSecurityGroupId = sgr.security_group_id
  where {{ partition_filter("rds") }}
  and vpc_sg.Status = 'active'
),
instances as (
    select * from {{ full_table_name("aws_rds_instances") }} rds
    where {{ partition_filter("rds") }}
),
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'RDS Instances should have restrictions on inbound access' as title,
    JSON_OBJECT() as metadata
    arn AS identifier,
    'fail' as status,
    tags
from instances
{% endmacro %}
