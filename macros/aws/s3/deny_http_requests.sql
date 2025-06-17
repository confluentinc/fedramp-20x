{% macro deny_http_requests(framework, check_id) %}
  {{ return(adapter.dispatch('deny_http_requests')(framework, check_id)) }}
{% endmacro %}

{% macro default__deny_http_requests(framework, check_id) %}{% endmacro %}

{% macro bigquery__deny_http_requests(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'S3 buckets should deny non-HTTPS requests' AS title,
    account_id,
    arn AS resource_id,
    'fail' AS status
FROM
    {{ full_table_name("aws_s3_buckets") }}
WHERE
    arn NOT IN (
        SELECT foo.arn
        FROM (
            SELECT
                b.arn,
                statements AS statement
            FROM
                {{ full_table_name("aws_s3_buckets") }} AS b
            inner join {{ full_table_name("aws_s3_bucket_policies") }} bp
            on bp._cq_parent_id = b._cq_id,
            UNNEST(JSON_QUERY_ARRAY(bp.policy_json.Statement)) AS statements
            WHERE
                CAST(JSON_VALUE(statements.Effect) AS STRING) = 'Deny'
                AND CAST(JSON_VALUE(JSON_EXTRACT(statements, '$.Condition.Bool."aws:SecureTransport"')) AS STRING) = 'false'
        ) AS foo
        WHERE
            CAST(JSON_VALUE(foo.statement.Principal) AS STRING) = '*'
            OR
            CONTAINS_SUBSTR(CAST(JSON_VALUE(foo.statement.Principal) AS STRING), '*')
    )
    and {{ partition_filter() }}
{% endmacro %}
