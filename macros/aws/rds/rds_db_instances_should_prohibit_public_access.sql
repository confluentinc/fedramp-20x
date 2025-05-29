{% macro rds_db_instances_should_prohibit_public_access(framework, check_id) %}
  {{ return(adapter.dispatch('rds_db_instances_should_prohibit_public_access')(framework, check_id)) }}
{% endmacro %}

{% macro default__rds_db_instances_should_prohibit_public_access(framework, check_id) %}{% endmacro %}

{% macro bigquery__rds_db_instances_should_prohibit_public_access(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Ensure that public access is not given to RDS Instance (Automated)' as title,
    arn as identifier,
    null as metadata,
    case when publicly_accessible is TRUE then 'fail' else 'pass' end as status
from {{ full_table_name("aws_rds_instances") }}
{% endmacro %}

