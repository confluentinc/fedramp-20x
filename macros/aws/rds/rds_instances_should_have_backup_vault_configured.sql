{% macro rds_instances_should_have_backup_vault_configured(framework, check_id) %}
  {{ return(adapter.dispatch('rds_instances_should_have_backup_vault_configured')(framework, check_id)) }}
{% endmacro %}

{% macro default__rds_instances_should_have_backup_vault_configured(framework, check_id) %}{% endmacro %}

{% macro bigquery__rds_instances_should_have_backup_vault_configured(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'RDS instances should have AWS Backup Vault configured' as title,
    rds.arn as identifier,
    null as metadata,
    case when bpr.arn is not null
        and vrp.status != 'EXPIRED'
        and DATE(vrp.creation_date) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
            then 'pass'
        else 'fail'
        end as status,
    rds.tags
from {{ full_table_name("aws_rds_instances") }} rds
left join {{ full_table_name("aws_backup_protected_resources") }} as bpr
    on bpr.resource_arn = rds.arn and {{ partition_join("bpr", "rds") }}
left join {{ full_table_name("aws_backup_vault_recovery_points")}} as vrp
    on bpr.last_recovery_point_arn = vrp.arn and {{ partition_join("bpr", "vrp") }}
where TIMESTAMP_TRUNC(rds._cq_sync_time, DAY) = TIMESTAMP(CURRENT_DATE())
    {% endmacro %}