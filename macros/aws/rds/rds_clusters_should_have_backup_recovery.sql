{% macro rds_clusters_should_have_backup_recovery(framework, check_id) %}
  {{ return(adapter.dispatch('rds_clusters_should_have_backup_recovery')(framework, check_id)) }}
{% endmacro %}

{% macro default__rds_clusters_should_have_backup_recovery(framework, check_id) %}{% endmacro %}

{% macro bigquery__rds_clusters_should_have_backup_recovery(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'RDS instances should have backups enabled' as title,
    account_id,
    arn AS resource_id,
    CASE
        WHEN backup_retention_period IS NULL
            OR backup_retention_period < 7 THEN 'fail'
        ELSE 'pass'
        END AS status
FROM {{ full_table_name("aws_rds_clusters") }}
    {% endmacro %}