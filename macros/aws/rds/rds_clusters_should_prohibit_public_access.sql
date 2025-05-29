{% macro rds_clusters_should_prohibit_public_access(framework, check_id) %}
  {{ return(adapter.dispatch('rds_clusters_should_prohibit_public_access')(framework, check_id)) }}
{% endmacro %}

{% macro default__rds_clusters_should_prohibit_public_access(framework, check_id) %}{% endmacro %}

{% macro bigquery__rds_clusters_should_prohibit_public_access(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'RDS DB instances should prohibit public access' as title,
    arn as identifier,
    null as metadata,
    case when publicly_accessible = TRUE then 'fail' else 'pass' end as status
from {{ full_table_name("aws_rds_instances") }}
{% endmacro %}