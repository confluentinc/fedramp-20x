{% macro rds_db_instances_should_be_encrypted_at_rest(framework, check_id) %}
  {{ return(adapter.dispatch('rds_db_instances_should_be_encrypted_at_rest')(framework, check_id)) }}
{% endmacro %}

{% macro default__rds_db_instances_should_be_encrypted_at_rest(framework, check_id) %}{% endmacro %}

{% macro bigquery__rds_db_instances_should_be_encrypted_at_rest(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'RDS DB instances should have encryption at rest enabled' as title,
    arn AS identifier,
    null AS metadata,
    case when storage_encrypted != TRUE then 'fail' else 'pass' end as status
from {{ full_table_name("aws_rds_instances") }}
{% endmacro %}