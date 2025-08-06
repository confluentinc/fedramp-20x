{% macro rds_instances_should_have_backup_enabled(framework, check_id) %}
  {{ return(adapter.dispatch('rds_instances_should_have_backup_enabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__rds_instances_should_have_backup_enabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__rds_instances_should_have_backup_enabled(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'RDS instances should have automatic backups enabled' as title,
    arn AS identifier,
    JSON_OBJECT() as metadata,
    CASE
        WHEN backup_retention_period IS NULL
            OR backup_retention_period < 7 THEN 'fail'
        ELSE 'pass'
        END AS status,
    tags
FROM {{ full_table_name("aws_rds_instances") }}
WHERE {{ partition_filter() }}
    {% endmacro %}
