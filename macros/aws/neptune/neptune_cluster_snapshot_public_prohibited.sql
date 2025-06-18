{% macro neptune_cluster_snapshot_public_prohibited(framework, check_id) %}
  {{ return(adapter.dispatch('neptune_cluster_snapshot_public_prohibited')(framework, check_id)) }}
{% endmacro %}

{% macro default__neptune_cluster_snapshot_public_prohibited(framework, check_id) %}{% endmacro %}

{% macro bigquery__neptune_cluster_snapshot_public_prohibited(framework, check_id) %}
SELECT
    '{{framework}}' AS framework,
    '{{check_id}}' AS check_id,
    'Neptune DB cluster snapshots should not be public' AS title,
    account_id,
    arn AS resource_id,
    CASE
        WHEN JSON_VALUE(a.AttributeName) = 'restore' 
        AND 'all' IN UNNEST(JSON_EXTRACT_STRING_ARRAY(a.AttributeValues))
        THEN 'fail'
        ELSE 'pass'
    END AS status
FROM 
    {{ full_table_name("aws_neptune_cluster_snapshots") }},
    UNNEST(JSON_QUERY_ARRAY(attributes)) AS a
where {{ partition_filter("aws_neptune_cluster_snapshots") }}
{% endmacro %}
