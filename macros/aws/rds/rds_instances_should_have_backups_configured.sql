{% macro rds_instances_should_have_backups_configured(framework, check_id) %}
  {{ return(adapter.dispatch('rds_instances_should_have_backups_configured')(framework, check_id)) }}
{% endmacro %}

{% macro default__rds_instances_should_have_backups_configured(framework, check_id) %}{% endmacro %}

{% macro bigquery__rds_instances_should_have_backups_configured(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'RDS instances should have automatic backups enabled' as title,
    arn as identifier,
    null as metadata,
    case when backup_retention_period is null
            or backup_retention_period < 7 then 'fail'
        else 'pass'
        end as status
    tags
from {{ full_table_name("aws_rds_instances") }}
    {% endmacro %}