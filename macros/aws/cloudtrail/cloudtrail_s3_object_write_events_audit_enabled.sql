{% macro cloudtrail_s3_object_write_events_audit_enabled(framework, check_id) %}
  {{ return(adapter.dispatch('cloudtrail_s3_object_write_events_audit_enabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__cloudtrail_s3_object_write_events_audit_enabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__cloudtrail_s3_object_write_events_audit_enabled(framework, check_id) %}
with audit_enabled AS (
    select
    c.arn,
    case
	when is_multi_region_trail and JSON_VALUE(data_resource.Type) = 'AWS::S3::Object'
    and 'arn:aws:s3' in UNNEST(JSON_EXTRACT_STRING_ARRAY(data_resource.Values))
    and JSON_VALUE(event_selectors.ReadWriteType) in ('WriteOnly', 'All')
     then True
	else False
	end as write_event
from {{ full_table_name("aws_cloudtrail_trails") }} AS c
join {{ full_table_name("aws_cloudtrail_trail_event_selectors") }} AS es ON c._cq_id = es._cq_parent_id,
UNNEST(JSON_QUERY_ARRAY(es.event_selectors.DataResources)) AS data_resource
where {{ partition_filter("c") }}
)

select 
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Ensure that Object-level logging for write events is enabled for S3 bucket' as title,
	c.account_id,
	c.arn as resource_id,
	case
	when LOGICAL_OR(write_event) then 'pass'
	else 'fail'
	end as status
from {{ full_table_name("aws_cloudtrail_trails") }} AS c
join audit_enabled AS cae ON c.arn = cae.arn
where {{ partition_filter("c") }}
group by c.arn, c.account_id
{% endmacro %}
