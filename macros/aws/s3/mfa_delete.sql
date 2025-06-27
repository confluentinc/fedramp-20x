{% macro mfa_delete(framework, check_id) %}
  {{ return(adapter.dispatch('mfa_delete')(framework, check_id)) }}
{% endmacro %}

{% macro default__mfa_delete(framework, check_id) %}{% endmacro %}

{% macro bigquery__mfa_delete(framework, check_id) %}
SELECT
  '{{framework}}' AS framework,
  '{{check_id}}' AS check_id,
  'Ensure MFA Delete is enabled on S3 buckets' AS title,
  b.account_id,
  b.arn AS resource_id,
  CASE
    WHEN 
	v.status is distinct from 'Enabled' or v.mfa_delete is distinct from 'Enabled' THEN 'fail'
    ELSE 'pass'
  END AS status
FROM
  {{ full_table_name("aws_s3_buckets") }} b
JOIN
  {{ full_table_name("aws_s3_bucket_versionings") }} v ON b.arn = v.bucket_arn
WHERE {{ partition_filter("b") }}
{% endmacro %}
