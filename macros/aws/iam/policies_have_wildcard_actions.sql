{% macro policies_have_wildcard_actions(framework, check_id) %}
  {{ return(adapter.dispatch('policies_have_wildcard_actions')(framework, check_id)) }}
{% endmacro %}

{% macro default__policies_have_wildcard_actions(framework, check_id) %}{% endmacro %}

{% macro bigquery__policies_have_wildcard_actions(framework, check_id) %}
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
    and {{ partition_join("p", "pv") }}
    where {{ partition_filter("p")}}
),
t_actions AS (
    SELECT
        id,
        statement AS statements,
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
    FROM t_actions,
        UNNEST(JSON_QUERY_ARRAY(actions)) AS action
    WHERE JSON_VALUE(statements.Effect) = 'Allow'
          AND JSON_VALUE(action) like '%:*'
    GROUP BY id
)
SELECT DISTINCT
    '{{framework}}' AS framework,
    '{{check_id}}' AS check_id,
    'IAM customer managed policies that you create should not allow wildcard actions for services' as title,
    p.account_id,
    p.arn AS resource_id,
    CASE WHEN
        v.id IS NOT NULL AND v.violations > 0
    THEN 'fail' ELSE 'pass' END AS status
FROM {{ full_table_name("aws_iam_policies") }} p
LEFT JOIN violations v ON v.id = p.id
where {{ partition_filter("p") }}
{% endmacro %}
