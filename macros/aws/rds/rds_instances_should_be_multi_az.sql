{% macro rds_instances_should_be_multi_az(framework, check_id) %}
  {{ return(adapter.dispatch('rds_instances_should_be_multi_az')(framework, check_id)) }}
{% endmacro %}

{% macro default__rds_instances_should_be_multi_az(framework, check_id) %}{% endmacro %}

{% macro bigquery__rds_instances_should_be_multi_az(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'RDS DB instances should be configured with multiple Availability Zones' as title,
    arn AS identifier,
    null AS metadata,
    case when multi_az != TRUE then 'fail' else 'pass' end as status
from {{ full_table_name("aws_rds_instances") }}
{% endmacro %}