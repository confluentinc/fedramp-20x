{% macro iam_support_role(framework, check_id) %}
  {{ return(adapter.dispatch('iam_support_role')(framework, check_id)) }}
{% endmacro %}

{% macro default__iam_support_role(framework, check_id) %}{% endmacro %}

{% macro bigquery__iam_support_role(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Ensure a support role has been created to manage incidents with AWS Support' as title,
    a.account_id,
    support_roles.role_arn AS resource_id,
    CASE
        WHEN support_roles.role_arn IS NOT NULL THEN 'pass'
        ELSE 'fail'
    END AS status
FROM
    {{ full_table_name("aws_iam_accounts") }} a
LEFT JOIN (
    select role_arn, rap.account_id from {{ full_table_name("aws_iam_role_attached_policies") }} rap
    join {{ full_table_name("aws_iam_roles") }} r on rap._cq_parent_id = r._cq_id
    where rap.policy_arn LIKE '%AWSSupportServiceRolePolicy%'
    and {{ partition_filter("rap") }}
) support_roles on a.account_id = support_roles.account_id
where {{ partition_filter("a") }}
{% endmacro %}
