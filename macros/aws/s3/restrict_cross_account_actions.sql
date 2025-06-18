{% macro restrict_cross_account_actions(framework, check_id) %}
  {{ return(adapter.dispatch('restrict_cross_account_actions')(framework, check_id)) }}
{% endmacro %}

{% macro default__restrict_cross_account_actions(framework, check_id) %}{% endmacro %}

{% macro bigquery__restrict_cross_account_actions(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Amazon S3 permissions granted to other AWS accounts in bucket policies should be restricted' as title,
    account_id,
    arn as resource_id,
    'fail' as status -- TODO FIXME
FROM (
    SELECT b.arn,
        b.account_id,
        b.name,
        b.region
        principals,
        actions
    FROM {{ full_table_name("aws_s3_buckets") }} b
        INNER JOIN {{ full_table_name("aws_s3_bucket_policies") }} ON b.arn = aws_s3_bucket_policies.bucket_arn and {{ partition_join("b", "aws_s3_bucket_policies") }},
        UNNEST(JSON_QUERY_ARRAY(aws_s3_bucket_policies.policy_json.Statement)) AS statements,
        UNNEST(JSON_QUERY_ARRAY(statements.Principal)) AS principals,
        UNNEST(JSON_QUERY_ARRAY(statements.Action)) AS actions
    WHERE JSON_VALUE(statements.Effect) = '"Allow"') AS flatten_statements
    AND {{ partition_filter("b") }}

WHERE
    -- Any cross account principals (or unknown principals) get flagged
    (
        CAST(principals AS STRING) NOT LIKE '"arn:aws:iam::' || account_id || ':%"'
        OR CAST(principals AS STRING) = '"*"'
    )
    -- Any broad permissions or Deletes get flagged
    AND (CAST(JSON_VALUE(actions) AS STRING) LIKE '"s3:%*"'
        OR CAST(JSON_VALUE(actions) AS STRING) LIKE '"s3:DeleteObject"')

-- This will flag ALL canoninical IDs as NOT COMPLIANT
-- This will flag ALL users that have been deleted as NOT COMPLIANT
-- This will not catch if an explicit deny supercedes the statement
{% endmacro %}
