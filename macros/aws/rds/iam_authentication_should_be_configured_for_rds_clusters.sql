{% macro iam_authentication_should_be_configured_for_rds_clusters(framework, check_id) %}
  {{ return(adapter.dispatch('iam_authentication_should_be_configured_for_rds_clusters')(framework, check_id)) }}
{% endmacro %}

{% macro default__iam_authentication_should_be_configured_for_rds_clusters(framework, check_id) %}{% endmacro %}

{% macro bigquery__iam_authentication_should_be_configured_for_rds_clusters(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'IAM authentication should be configured for RDS clusters' as title,
    account_id,
    arn AS resource_id,
    case when iam_database_authentication_enabled != TRUE then 'fail' else 'pass' end as status
from {{ full_table_name("aws_rds_clusters") }}
where {{ partition_filter() }}
{% endmacro %}
