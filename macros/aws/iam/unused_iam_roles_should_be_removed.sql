{% macro unused_iam_roles_should_be_removed(framework, check_id) %}
  {{ return(adapter.dispatch('unused_iam_roles_should_be_removed')(framework, check_id)) }}
{% endmacro %}

{% macro default__unused_iam_roles_should_be_removed(framework, check_id) %}{% endmacro %}

{% macro bigquery__unused_iam_roles_should_be_removed(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'IAM roles should be used within 90 days of last use' as title,
    arn as identifier,
    JSON_OBJECT() as metadata,
    case when
        role_last_used_last_used_date is not null
        and DATETIME_DIFF(CURRENT_DATETIME(), DATETIME(role_last_used_last_used_date), DAY) > 90
        then 'fail'
        else 'pass'
    end as status,
    tags
from {{ full_table_name("aws_iam_roles") }}
where {{ partition_filter() }}
{% endmacro %}
