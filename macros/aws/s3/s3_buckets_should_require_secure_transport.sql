{% macro s3_buckets_should_require_secure_transport(framework, check_id) %}
  {{ return(adapter.dispatch('s3_buckets_should_require_secure_transport')(framework, check_id)) }}
{% endmacro %}

{% macro default__s3_buckets_should_require_secure_transport(framework, check_id) %}{% endmacro %}

{% macro bigquery__s3_buckets_should_require_secure_transport(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'S3 Buckets should block insecure transports' as title,
    arn as identifier,
    JSON_OBJECT() as metadata,
    case when (
        select 1 from unnest(JSON_QUERY_ARRAY(policies.policy, '$.Statement')) statement
        where JSON_VALUE(statement, '$.Effect' ) = 'Deny'
        and JSON_VALUE(statement, '$.Condition.Bool."aws:SecureTransport"') = 'false'
        or JSON_VALUE(statement, '$.Condition.StringEquals."aws:SecureTransport"') = 'false'
        limit 1
        ) = 1
        then 'pass'
        else 'fail'
    end as status,
    tags
from {{ full_table_name("aws_s3_buckets") }} buckets
left join {{ full_table_name("aws_s3_bucket_policies") }} policies
on buckets.arn = policies.bucket_arn
    and timestamp_trunc(policies._cq_sync_time, day) = TIMESTAMP(CURRENT_DATE())
WHERE TIMESTAMP_TRUNC(buckets._cq_sync_time, DAY) = TIMESTAMP(CURRENT_DATE())
    {% endmacro %}
