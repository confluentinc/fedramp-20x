{% macro iam_customer_policy_no_kms_decrypt(framework, check_id) %}
  {{ return(adapter.dispatch('iam_customer_policy_no_kms_decrypt')(framework, check_id)) }}
{% endmacro %}

{% macro default__iam_customer_policy_no_kms_decrypt(framework, check_id) %}{% endmacro %}

{% macro bigquery__iam_customer_policy_no_kms_decrypt(framework, check_id) %}
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
    where {{ partition_filter("p")}}
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
          AND (JSON_VALUE(resource) = '*' or JSON_VALUE(resource) like '%kms%')
          AND ( JSON_VALUE(action) = '*' or JSON_VALUE(action) = 'kms:Decrypt' or JSON_VALUE(action) = 'kms:ReEncryptFrom')
    GROUP BY id
)
SELECT DISTINCT
    '{{framework}}' AS framework,
    '{{check_id}}' AS check_id,
    'IAM customer managed policies should not allow decryption actions on all KMS keys' AS title,
    p.account_id,
    p.arn AS resource_id,
    CASE WHEN
        v.id IS NOT NULL AND v.violations > 0
    THEN 'fail' ELSE 'pass' END AS status
FROM {{ full_table_name("aws_iam_policies") }} p
LEFT JOIN violations v ON v.id = p.id
where {{ partition_filter("p") }}
{% endmacro %}
