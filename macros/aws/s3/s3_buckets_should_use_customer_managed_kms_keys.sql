{% macro s3_buckets_should_use_customer_managed_kms_keys(framework, check_id) %}
  {{ return(adapter.dispatch('s3_buckets_should_use_customer_managed_kms_keys')(framework, check_id)) }}
{% endmacro %}

{% macro default__s3_buckets_should_use_customer_managed_kms_keys(framework, check_id) %}{% endmacro %}

{% macro bigquery__s3_buckets_should_use_customer_managed_kms_keys(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'S3 buckets should use customer-managed KMS keys for encryption' as title,
    buckets.arn as identifier,
    JSON_OBJECT(
        'bucket_name', buckets.name,
        'sse_algorithm', JSON_VALUE(encrules.apply_server_side_encryption_by_default, '$.SSEAlgorithm'),
        'kms_key_id', JSON_VALUE(encrules.apply_server_side_encryption_by_default, '$.KMSMasterKeyID'),
        'bucket_key_enabled', encrules.bucket_key_enabled
    ) as metadata,
    case
        when JSON_VALUE(encrules.apply_server_side_encryption_by_default, '$.SSEAlgorithm') IS NULL then 'fail'
        when JSON_VALUE(encrules.apply_server_side_encryption_by_default, '$.SSEAlgorithm') = 'AES256' then 'fail'
        when JSON_VALUE(encrules.apply_server_side_encryption_by_default, '$.KMSMasterKeyID') LIKE '%alias/aws/s3%' then 'fail'
        when JSON_VALUE(encrules.apply_server_side_encryption_by_default, '$.KMSMasterKeyID') LIKE '%:key/%' then 'pass'
        else 'fail'
    end as status,
    buckets.tags
from {{ full_table_name("aws_s3_buckets") }} buckets
left join {{ full_table_name("aws_s3_bucket_encryption_rules") }} encrules
on buckets._cq_id = encrules._cq_parent_id
and {{ partition_join("buckets", "encrules") }}
where {{ partition_filter("buckets") }}
{% endmacro %}
