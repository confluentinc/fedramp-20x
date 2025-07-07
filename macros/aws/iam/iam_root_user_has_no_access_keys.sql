{% macro iam_root_user_has_no_access_keys(framework, check_id) %}
  {{ return(adapter.dispatch('iam_root_user_has_no_access_keys')(framework, check_id)) }}
{% endmacro %}

{% macro default__iam_root_user_has_no_access_keys(framework, check_id) %}{% endmacro %}

{% macro bigquery__iam_root_user_has_no_access_keys(framework, check_id) %}

select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'AWS Root Accounts should not have active access credentials' as title,
    arn as identifier,
    JSON_OBJECT() as metadata,
    case when access_key1_active = true or access_key2_active = true
        then 'fail'
        else 'pass'
    end as status,
    JSON_OBJECT() as tags
from {{ full_table_name("aws_iam_credential_reports") }}
where user = '<root_account>'
and {{ partition_filter() }}

{% endmacro %}