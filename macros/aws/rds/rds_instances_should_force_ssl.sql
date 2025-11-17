{% macro rds_instances_should_force_ssl(framework, check_id) %}
  {{ return(adapter.dispatch('rds_instances_should_force_ssl')(framework, check_id)) }}
{% endmacro %}

{% macro default__rds_instances_should_force_ssl(framework, check_id) %}{% endmacro %}

{% macro bigquery__rds_instances_should_force_ssl(framework, check_id) %}
with databases as (
    select i.arn, JSON_VALUE(pg.DBParameterGroupName) as group_name, dbpg.arn as group_arn, i.tags
    from {{ full_table_name("aws_rds_instances") }} i
    left join unnest(JSON_QUERY_ARRAY(db_parameter_groups)) pg
    left join {{ full_table_name("aws_rds_db_parameter_groups") }} dbpg
      on JSON_VALUE(pg.DBParameterGroupName) = dbpg.db_parameter_group_name
      and i.account_id = dbpg.account_id
      and i.region = dbpg.region
      and {{ partition_join("i", "dbpg") }}
    where {{ partition_filter("i") }}
    )
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'RDS Instances should be configured to require SSL communication' as title,
    arn as identifier,
    JSON_OBJECT() as metadata,
    case when exists(
        select 1 from {{ full_table_name("aws_rds_db_parameter_group_db_parameters") }}
        where db_parameter_group_arn = group_arn
          and parameter_name = 'rds.force_ssl'
          and parameter_value = '1'
    ) then 'pass' else 'fail' end as status,
    tags as tags
from databases
{% endmacro %}
