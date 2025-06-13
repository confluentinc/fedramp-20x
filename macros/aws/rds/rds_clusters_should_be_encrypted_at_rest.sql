{% macro rds_instances_should_be_encrypted_at_rest(framework, check_id) %}
  {{ return(adapter.dispatch('rds_instances_should_be_encrypted_at_rest')(framework, check_id)) }}
{% endmacro %}

{% macro default__rds_instances_should_be_encrypted_at_rest(framework, check_id) %}{% endmacro %}

{% macro bigquery__rds_instances_should_be_encrypted_at_rest(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'RDS Instances should be encrypted at rest' as title,
    arn as identifier,
    null as metadata,
    case when storage_encrypted = true
             then 'pass'
         else 'fail'
        end as status
from {{ full_table_name("aws_rds_instances") }}
WHERE {{ partition_filter() }}
{% endmacro %}