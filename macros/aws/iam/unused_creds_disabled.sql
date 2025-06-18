{% macro unused_creds_disabled(framework, check_id) %}
  {{ return(adapter.dispatch('unused_creds_disabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__unused_creds_disabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__unused_creds_disabled(framework, check_id) %}
select
  '{{framework}}' as framework,
  '{{check_id}}' as check_id,
  'Ensure credentials unused for 90 days or greater are disabled (Scored)' as title,
  SPLIT(arn, ':')[SAFE_OFFSET(4)] AS account_id,
  r.arn,
  case when 
      (r.password_status IN ('TRUE', 'true') and r.password_last_used < TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
        or (k.last_used < TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)))
      then 'fail'
      else 'pass'
  end
from {{ full_table_name("aws_iam_credential_reports") }} r
left join {{ full_table_name("aws_iam_user_access_keys") }} k on k.user_arn = r.arn
where {{ partition_filter("r") }}
{% endmacro %}
