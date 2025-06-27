{% macro iam_inline_policy_no_kms_decrypt(framework, check_id) %}
  {{ return(adapter.dispatch('iam_inline_policy_no_kms_decrypt')(framework, check_id)) }}
{% endmacro %}

{% macro default__iam_inline_policy_no_kms_decrypt(framework, check_id) %}{% endmacro %}

{% macro bigquery__iam_inline_policy_no_kms_decrypt(framework, check_id) %}
 WITH pdu AS (
    SELECT
        u.user_arn AS arn,
        u.account_id AS account_id,
        CASE 
            WHEN JSON_TYPE(u.policy_document.Statement) != 'array' THEN
                PARSE_JSON(CONCAT('[', TO_JSON_STRING(u.policy_document.Statement), ']'))
            ELSE
                u.policy_document.Statement
        END AS statements
    FROM {{ full_table_name("aws_iam_user_policies") }} u
    where {{ partition_filter("u") }}
),
pdr AS (
    SELECT
        r.role_arn AS arn,
        r.account_id AS account_id,
        CASE 
            WHEN JSON_TYPE(r.policy_document.Statement) != 'array' THEN
                PARSE_JSON(CONCAT('[', TO_JSON_STRING(r.policy_document.Statement), ']'))
            ELSE
                r.policy_document.Statement
        END AS statements
    FROM {{ full_table_name("aws_iam_role_policies") }} r
    where {{ partition_filter("r") }}
),
pdg AS (
    SELECT
        g.group_arn AS arn,
        g.account_id AS account_id,
        CASE 
            WHEN JSON_TYPE(g.policy_document.Statement) != 'array' THEN
                PARSE_JSON(CONCAT('[', TO_JSON_STRING(g.policy_document.Statement), ']'))
            ELSE
                g.policy_document.Statement
        END AS statements
    FROM {{ full_table_name("aws_iam_group_policies") }} g
    where {{ partition_filter("g") }}
),
resources_actions AS (
    SELECT
        arn,
        account_id,
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
    FROM (
        SELECT * FROM pdu
        UNION ALL
        SELECT * FROM pdr
        UNION ALL
        SELECT * FROM pdg
    ) AS combined_policies,
    UNNEST(JSON_QUERY_ARRAY(statements)) AS statement
),
decrypt_policies AS (
    SELECT
        arn,
        COUNT(*) AS violations
    FROM resources_actions,
        UNNEST(JSON_QUERY_ARRAY(resources)) AS resource,
        UNNEST(JSON_QUERY_ARRAY(actions)) AS action
    WHERE JSON_VALUE(statements.Effect) = 'Allow'
          AND (JSON_VALUE(resource) = '*' OR JSON_VALUE(resource) LIKE '%kms%')
          AND (JSON_VALUE(action) = 'kms:Decrypt' OR JSON_VALUE(action) = 'kms:ReEncryptFrom')
    GROUP BY arn
)
SELECT DISTINCT
    '{{framework}}' AS framework,
    '{{check_id}}' AS check_id,
    'IAM policies should not allow full * administrative privileges' AS title,
    u.account_id,
    u.arn AS resource_id,
    CASE
    WHEN dp.arn IS NOT NULL THEN 'fail'
    ELSE 'pass'
    END AS status
FROM (
    SELECT arn, account_id FROM {{ full_table_name("aws_iam_users") }} where {{ partition_filter() }}
    UNION ALL
    SELECT arn, account_id FROM {{ full_table_name("aws_iam_roles") }} WHERE arn NOT LIKE '%service-role/%' and {{ partition_filter() }}
    UNION ALL
    SELECT arn, account_id FROM {{ full_table_name("aws_iam_groups") }} where {{ partition_filter() }}
) AS u
LEFT JOIN decrypt_policies dp
    ON u.arn = dp.arn
{% endmacro %}
