{% macro s3_buckets_should_not_be_publicly_accessible(framework, check_id) %}
  {{ return(adapter.dispatch('s3_buckets_should_not_be_publicly_accessible')(framework, check_id)) }}
{% endmacro %}

{% macro default__s3_buckets_should_not_be_publicly_accessible(framework, check_id) %}{% endmacro %}

{% macro bigquery__s3_buckets_should_not_be_publicly_accessible(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'S3 Block Public Access setting should be enabled at the bucket-level' AS title,
    b.arn AS identifier,
    null AS metadata,
    CASE
        when CAST( JSON_VALUE(pab.public_access_block_configuration.block_public_acls) AS BOOL)
            and CAST( JSON_VALUE(pab.public_access_block_configuration.block_public_policy) AS BOOL)
            and CAST( JSON_VALUE(pab.public_access_block_configuration.ignore_public_acls) AS BOOL)
            and CAST( JSON_VALUE(pab.public_access_block_configuration.restrict_public_buckets) AS BOOL)
            THEN 'pass'
        ELSE 'fail'
        END AS status
FROM
    {{ full_table_name("aws_s3_buckets") }}
    as b
LEFT JOIN
    {{ full_table_name("aws_s3_bucket_public_access_blocks") }}
 as pab on pab.bucket_arn = b.arn
    {% endmacro %}