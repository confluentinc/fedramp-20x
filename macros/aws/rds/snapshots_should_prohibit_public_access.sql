{% macro snapshots_should_prohibit_public_access(framework, check_id) %}
  {{ return(adapter.dispatch('snapshots_should_prohibit_public_access')(framework, check_id)) }}
{% endmacro %}

{% macro default__snapshots_should_prohibit_public_access(framework, check_id) %}{% endmacro %}

{% macro bigquery__snapshots_should_prohibit_public_access(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'RDS snapshots should be private' as title,
    account_id,
    arn AS resource_id,
    case when
         (JSON_VALUE(attrs.AttributeName) is not distinct from 'restore')
         and JSON_VALUE(attrs.AttributeValues) = 'all'
    then 'fail' else 'pass' end as status
from {{ full_table_name("aws_rds_cluster_snapshots") }},
      UNNEST(JSON_QUERY_ARRAY(attributes)) as attrs
where {{ partition_filter("aws_rds_cluster_snapshots") }}
{% endmacro %}
