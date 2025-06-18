{% macro cloudtrail_bucket_not_public(framework, check_id) %}
  {{ return(adapter.dispatch('cloudtrail_bucket_not_public')(framework, check_id)) }}
{% endmacro %}

{% macro default__cloudtrail_bucket_not_public(framework, check_id) %}{% endmacro %}

{% macro bigquery__cloudtrail_bucket_not_public(framework, check_id) %}
with public_bucket_data as (
select
	aws_s3_buckets.account_id,
	aws_s3_buckets.arn,
    COUNTIF (
        JSON_VALUE(grantee.URI) like '%acs.amazonaws.com/groups/global/AllUsers'
        or
        JSON_VALUE(grantee.URI) like '%acs.amazonaws.com/groups/global/AuthenticatedUsers'
    ) as users_grants,
	COUNTIF (
        JSON_VALUE(statements.Effect) = 'Allow'
		and
		(
      JSON_VALUE(statements.Principal) = '"*"'
      or
      '"*"' IN UNNEST(JSON_EXTRACT_STRING_ARRAY(statements.Principal.AWS))
		 )
        
    ) as anon_statements
from {{ full_table_name("aws_cloudtrail_trails") }}
inner join {{ full_table_name("aws_s3_buckets") }} on aws_cloudtrail_trails.s3_bucket_name = aws_s3_buckets.name
left join {{ full_table_name("aws_s3_bucket_grants") }} on aws_s3_bucket_grants._cq_parent_id = aws_s3_buckets._cq_id
left join {{ full_table_name("aws_s3_bucket_policies") }} on aws_s3_bucket_policies._cq_parent_id = aws_s3_buckets._cq_id,
UNNEST(JSON_QUERY_ARRAY(aws_s3_bucket_policies.policy_json.Statement)) AS statements,
UNNEST(JSON_QUERY_ARRAY(statements.Principal)) AS principals
where {{ partition_filter("aws_cloudtrail_trails") }}
group by
    aws_s3_buckets.account_id,
	aws_s3_buckets.arn
	)
select 
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Ensure the S3 bucket used to store CloudTrail logs is not publicly accessible' as title,
	account_id,
	arn as resource_id,
	case
	when users_grants > 0 then 'fail'
    when anon_statements > 0 then 'fail'
	else 'pass'
	end as status
from public_bucket_data
{% endmacro %}
