{% macro mfa_enabled_for_console_access(framework, check_id) %}
  {{ return(adapter.dispatch('mfa_enabled_for_console_access')(framework, check_id)) }}
{% endmacro %}

{% macro default__mfa_enabled_for_console_access(framework, check_id) %}{% endmacro %}

{% macro bigquery__mfa_enabled_for_console_access(framework, check_id) %}
select
  '{{framework}}' As framework,
  '{{check_id}}' As check_id,
  'Ensure MFA is enabled for all IAM users that have a console password (Scored)' as title,
  SPLIT(arn, ':')[SAFE_OFFSET(4)] as account_id,
  arn as resource_id,
  case when
    password_status IN ('TRUE', 'true') and not mfa_active
    then 'fail'
    else 'pass'
  end as status
from {{ full_table_name("aws_iam_credential_reports") }}
where {{ partition_filter() }}
{% endmacro %}
