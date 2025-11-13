{% macro s3_buckets_should_have_lifecycle_policies(framework, check_id) %}
  {{ return(adapter.dispatch('s3_buckets_should_have_lifecycle_policies')(framework, check_id)) }}
{% endmacro %}

{% macro default__s3_buckets_should_have_lifecycle_policies(framework, check_id) %}{% endmacro %}

{% macro bigquery__s3_buckets_should_have_lifecycle_policies(framework, check_id) %}
-- Check S3 buckets have lifecycle policies for data removal
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'S3 buckets should have lifecycle policies for data management' as title,
    b.arn as identifier,
    JSON_OBJECT() as metadata,
    case when
        NOT EXISTS(
            select 1 from {{ full_table_name("aws_s3_bucket_lifecycles") }} bl2
            where b.arn = bl2.bucket_arn
        )
        then 'fail'
        else 'pass'
    end as status,
    b.tags as tags
from {{ full_table_name("aws_s3_buckets") }} b
where {{ partition_filter("b") }}
{% endmacro %}
