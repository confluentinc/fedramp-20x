{% macro rds_snapshots_public_prohibited(framework, check_id) %}
  {{ return(adapter.dispatch('rds_snapshots_public_prohibited')(framework, check_id)) }}
{% endmacro %}

{% macro default__rds_snapshots_public_prohibited(framework, check_id) %}{% endmacro %}

{% macro bigquery__rds_snapshots_public_prohibited(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'RDS snapshot should be private' AS title,
    account_id,
    arn AS resource_id,
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
    account_id,
    arn AS resource_id,
    CASE 
        WHEN JSON_VALUE(a.AttributeName) = 'restore' and 'all' IN UNNEST(JSON_EXTRACT_STRING_ARRAY(a.AttributeValues)) THEN 'fail'
        ELSE 'pass'
    END AS status
FROM
    {{ full_table_name("aws_rds_db_snapshots") }},
    UNNEST(JSON_QUERY_ARRAY(ATTRIBUTES)) AS a
where {{ partition_filter("aws_rds_db_snapshots") }}
{% endmacro %}
