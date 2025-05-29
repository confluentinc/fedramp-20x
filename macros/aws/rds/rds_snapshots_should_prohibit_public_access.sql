{% macro rds_snapshots_should_prohibit_public_access(framework, check_id) %}
  {{ return(adapter.dispatch('rds_snapshots_should_prohibit_public_access')(framework, check_id)) }}
{% endmacro %}

{% macro default__rds_snapshots_should_prohibit_public_access(framework, check_id) %}{% endmacro %}

{% macro bigquery__rds_snapshots_should_prohibit_public_access(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'RDS snapshot should be private' AS title,
    arn AS identifier,
    null as metadata,
    CASE
        WHEN JSON_VALUE(a.AttributeName) = 'restore' and 'all' IN UNNEST(JSON_EXTRACT_STRING_ARRAY(a.AttributeValues)) THEN 'fail'
    ELSE 'pass'
END AS status
FROM
    {{ full_table_name("aws_rds_cluster_snapshots") }},
    UNNEST(JSON_QUERY_ARRAY(ATTRIBUTES)) AS a

UNION ALL

SELECT
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'RDS snapshot should be private' AS title,
    arn AS identifier,
    null as metadata,
    CASE
        WHEN JSON_VALUE(a.AttributeName) = 'restore' and 'all' IN UNNEST(JSON_EXTRACT_STRING_ARRAY(a.AttributeValues)) THEN 'fail'
    ELSE 'pass'
END AS status
FROM
    {{ full_table_name("aws_rds_db_snapshots") }},
    UNNEST(JSON_QUERY_ARRAY(ATTRIBUTES)) AS a

UNION ALL

select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'RDS snapshots should be private' as title,
    arn AS identifier,
    null as metadata,
    case when
             (JSON_VALUE(attrs.AttributeName) is not distinct from 'restore')
                 and JSON_VALUE(attrs.AttributeValues) = 'all'
             then 'fail' else 'pass' end as status
from {{ full_table_name("aws_rds_cluster_snapshots") }},
     UNNEST(JSON_QUERY_ARRAY(attributes)) as attrs

{% endmacro %}