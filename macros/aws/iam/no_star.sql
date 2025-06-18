{% macro no_star(framework, check_id) %}
  {{ return(adapter.dispatch('no_star')(framework, check_id)) }}
{% endmacro %}

{% macro default__no_star(framework, check_id) %}{% endmacro %}

{% macro bigquery__no_star(framework, check_id) %}
WITH pvs AS (
    SELECT
        p.id AS id,
        CASE 
            WHEN JSON_TYPE(pv.document_json.Statement) != 'array' THEN
                PARSE_JSON(CONCAT('[', TO_JSON_STRING(pv.document_json.Statement), ']'))
            ELSE
                pv.document_json.Statement
        END AS statements
    FROM {{ full_table_name("aws_iam_policies") }} p
    JOIN {{ full_table_name("aws_iam_policy_default_versions") }} pv ON pv._cq_parent_id = p._cq_id
    WHERE p.arn not like 'arn:aws:iam::aws:policy%'
    AND {{ partition_filter("p") }}
),
resources_actions AS (
    SELECT
        id,
        statement AS statements,
        CASE 
            WHEN JSON_TYPE(JSON_EXTRACT(statement, '$.Resource')) != 'array' THEN
                PARSE_JSON(CONCAT('[', TO_JSON_STRING(statement.Resource), ']'))
            ELSE
                statement.Resource
        END AS resources,
        CASE 
            WHEN JSON_TYPE(JSON_EXTRACT(statement, '$.Action')) != 'array' THEN
                PARSE_JSON(CONCAT('[', TO_JSON_STRING(statement.Action), ']'))
            ELSE
                statement.Action
        END AS actions
    FROM pvs,
    UNNEST(JSON_QUERY_ARRAY(statements)) AS statement
),
violations AS (
    SELECT
        id,
        COUNT(*) AS violations
    FROM resources_actions,
        UNNEST(JSON_QUERY_ARRAY(resources)) AS resource,
        UNNEST(JSON_QUERY_ARRAY(actions)) AS action
    WHERE JSON_VALUE(statements.Effect) = 'Allow'
          AND JSON_VALUE(resource) = '*'
          AND (JSON_VALUE(action) = '*' OR JSON_VALUE(action) = '*:*')
    GROUP BY id
)
SELECT DISTINCT
    '{{framework}}' AS framework,
    '{{check_id}}' AS check_id,
    'IAM policies should not allow full * administrative privileges' AS title,
    p.account_id,
    p.arn AS resource_id,
    CASE WHEN
        v.id IS NOT NULL AND v.violations > 0
    THEN 'fail' ELSE 'pass' END AS status
FROM {{ full_table_name("aws_iam_policies") }} p
LEFT JOIN violations v ON v.id = p.id
WHERE {{ partition_filter("p") }}
{% endmacro %}
