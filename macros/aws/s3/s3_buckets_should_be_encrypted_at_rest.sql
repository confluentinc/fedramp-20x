{% macro s3_buckets_should_be_encrypted_at_rest(framework, check_id) %}
  {{ return(adapter.dispatch('s3_buckets_should_be_encrypted_at_rest')(framework, check_id)) }}
{% endmacro %}

{% macro default__s3_buckets_should_be_encrypted_at_rest(framework, check_id) %}{% endmacro %}

{% macro bigquery__s3_buckets_should_be_encrypted_at_rest(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'S3 Buckets should be encrypted at rest' as title,
    arn as identifier,
    null as metadata,
    case when encrules.apply_server_side_encryption_by_default IS NOT NULL
        then 'pass'
        else 'fail'
    end as status
from {{ full_table_name("aws_s3_buckets") }} buckets
left join {{ full_table_name("aws_s3_bucket_encryption_rules") }} encrules
on buckets.arn = encrules.bucket_arn
{% endmacro %}
