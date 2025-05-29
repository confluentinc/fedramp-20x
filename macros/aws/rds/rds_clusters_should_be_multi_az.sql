{% macro rds_clusters_should_be_multi_az(framework, check_id) %}
  {{ return(adapter.dispatch('rds_clusters_should_be_multi_az')(framework, check_id)) }}
{% endmacro %}

{% macro default__rds_clusters_should_be_multi_az(framework, check_id) %}{% endmacro %}

{% macro bigquery__rds_clusters_should_be_multi_az(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'RDS DB clusters should be configured for multiple Availability Zones' as title,
    arn AS identifier,
    null AS metadadta,
    case when multi_az != TRUE then 'fail' else 'pass' end as status
from {{ full_table_name("aws_rds_clusters") }}
{% endmacro %}