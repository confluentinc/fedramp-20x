{% macro s3_bucket_level_public_access_prohibited(framework, check_id) %}
  {{ return(adapter.dispatch('s3_bucket_level_public_access_prohibited')(framework, check_id)) }}
{% endmacro %}

{% macro default__s3_bucket_level_public_access_prohibited(framework, check_id) %}{% endmacro %}

{% macro bigquery__s3_bucket_level_public_access_prohibited(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'S3 Block Public Access setting should be enabled at the bucket-level' AS title,
    b.account_id,
    b.arn AS resource_id,
    CASE
    when CAST( JSON_VALUE(pab.public_access_block_configuration.BlockPublicAcls) AS BOOL)
    and CAST( JSON_VALUE(pab.public_access_block_configuration.BlockPublicPolicy) AS BOOL)
    and CAST( JSON_VALUE(pab.public_access_block_configuration.IgnorePublicAcls) AS BOOL)
    and CAST( JSON_VALUE(pab.public_access_block_configuration.RestrictPublicBuckets) AS BOOL)
    THEN 'pass'
        ELSE 'fail'
    END AS status
FROM
    {{ full_table_name("aws_s3_buckets") }}
 as b
LEFT JOIN
    {{ full_table_name("aws_s3_bucket_public_access_blocks") }}
 as pab on pab.bucket_arn = b.arn
where {{ partition_filter("b") }}
{% endmacro %}
