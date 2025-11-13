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
    b.account_id,
    b.name as resource_id,
    case when
        bl.lifecycle_rules is null
        or JSON_EXTRACT_ARRAY(bl.lifecycle_rules) = []
        then 'fail'
        else 'pass'
    end as status
from {{ full_table_name("aws_s3_buckets") }} b
left join {{ full_table_name("aws_s3_bucket_lifecycles") }} bl 
    on b.arn = bl.bucket_arn
    and {{ partition_filter("bl") }}
where {{ partition_filter("b") }}
{% endmacro %}
