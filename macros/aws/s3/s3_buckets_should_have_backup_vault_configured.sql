{% macro s3_buckets_should_have_backup_vault_configured(framework, check_id) %}
  {{ return(adapter.dispatch('s3_buckets_should_have_backup_vault_configured')(framework, check_id)) }}
{% endmacro %}

{% macro default__s3_buckets_should_have_backup_vault_configured(framework, check_id) %}{% endmacro %}

{% macro bigquery__s3_buckets_should_have_backup_vault_configured(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'S3 buckets should have AWS Backup Vault configured' as title,
    s3.arn as identifier,
    null as metadata,
    case when bpr.arn is not null
        and vrp.status != 'EXPIRED'
        and DATE(vrp.creation_date) >= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY)
    then 'pass'
    else 'fail'
end as status,
    rds.tags
from {{ full_table_name("aws_s3_buckets") }} s3
left join {{ full_table_name("aws_backup_protected_resources") }} as bpr
    on bpr.resource_arn = s3.arn
left join {{ full_table_name("aws_backup_vault_recovery_points")}} as vrp
    on bpr.last_recovery_point_arn = vrp.arn
where TIMESTAMP_TRUNC(s3._cq_sync_time, DAY) = TIMESTAMP(CURRENT_DATE())
    {% endmacro %}