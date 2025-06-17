{% macro instances_should_have_deletion_protection_enabled(framework, check_id) %}
  {{ return(adapter.dispatch('instances_should_have_deletion_protection_enabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__instances_should_have_deletion_protection_enabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__instances_should_have_deletion_protection_enabled(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'RDS DB instances should have deletion protection enabled' as title,
    account_id,
    arn AS resource_id,
    case when deletion_protection != TRUE then 'fail' else 'pass' end as status
from {{ full_table_name("aws_rds_instances") }}
where {{ partition_filter() }}
{% endmacro %}
