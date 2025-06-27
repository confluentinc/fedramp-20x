{% macro iam_access_keys_rotated_more_than_90_days(framework, check_id) %}
  {{ return(adapter.dispatch('iam_access_keys_rotated_more_than_90_days')(framework, check_id)) }}
{% endmacro %}

{% macro default__iam_access_keys_rotated_more_than_90_days(framework, check_id) %}{% endmacro %}

{% macro bigquery__iam_access_keys_rotated_more_than_90_days(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'IAM users access keys should be rotated every 90 days or less' AS title,
    account_id,
    access_key_id AS resource_id,
    CASE 
        WHEN DATETIME_DIFF(CURRENT_DATETIME(), DATETIME(last_rotated), DAY) > 90 
        THEN 'fail'
        ELSE 'pass'
    END AS status
from {{ full_table_name("aws_iam_user_access_keys") }}
where {{ partition_filter() }}
{% endmacro %}
