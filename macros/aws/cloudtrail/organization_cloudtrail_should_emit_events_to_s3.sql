{% macro organization_cloudtrail_should_emit_events_to_s3(framework, check_id) %}
  {{ return(adapter.dispatch('organization_cloudtrail_should_emit_events_to_s3')(framework, check_id)) }}
{% endmacro %}

{% macro default__organization_cloudtrail_should_emit_events_to_s3(framework, check_id) %}{% endmacro %}

{% macro bigquery__organization_cloudtrail_should_emit_events_to_s3(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Cloudtrail should emit change logs to S3 for review' as title,
    CONCAT('arn:', CASE WHEN region like '%-gov-%' then 'aws-us-gov' else 'aws' end, ':iam::', account_id, ':root') as identifier,
    JSON_OBJECT('trail_arn', arn) as metadata,
    case when
        s3_bucket_name is not null and
        JSON_VALUE(status, '$.IsLogging') = 'true'
         then 'pass'
         else 'fail'
    end as status,
    tags
from {{ full_table_name("aws_cloudtrail_trails") }}
where is_organization_trail = true
and {{ partition_filter() }}
    {% endmacro %}