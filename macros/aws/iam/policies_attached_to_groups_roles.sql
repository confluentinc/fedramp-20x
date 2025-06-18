{% macro policies_attached_to_groups_roles(framework, check_id) %}
  {{ return(adapter.dispatch('policies_attached_to_groups_roles')(framework, check_id)) }}
{% endmacro %}

{% macro default__policies_attached_to_groups_roles(framework, check_id) %}{% endmacro %}

{% macro bigquery__policies_attached_to_groups_roles(framework, check_id) %}
select distinct
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'IAM users should not have IAM policies attached' as title,
    aws_iam_users.account_id,
    arn AS resource_id,
    case 
        when
            aws_iam_user_attached_policies.user_arn is not null
            or aws_iam_user_policies.user_arn is not null
        then 'fail' 
        else 'pass' 
    end as status
from {{ full_table_name("aws_iam_users") }}
left join {{ full_table_name("aws_iam_user_attached_policies") }} on aws_iam_users.arn = aws_iam_user_attached_policies.user_arn and {{ partition_join("aws_iam_users", "aws_iam_user_attached_policies") }}
left join {{ full_table_name("aws_iam_user_policies") }} on aws_iam_users.arn = aws_iam_user_policies.user_arn and {{ partition_join("aws_iam_users", "aws_iam_user_policies") }}
where {{ partition_filter("aws_iam_users") }}
{% endmacro %}
