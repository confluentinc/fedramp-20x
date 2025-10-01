{% macro organization_policy_check(framework, check_id, title, blocked_actions, check, condition_key, condition_value) %}
  {{ return(adapter.dispatch('organization_policy_check')(framework, check_id, title, blocked_actions, check, condition_key, condition_value)) }}
{% endmacro %}

{% macro default__organization_policy_check(framework, check_id, title, blocked_actions, check, condition_key, condition_value) %}{% endmacro %}

{% macro bigquery__organization_policy_check(framework, check_id, title, blocked_actions, check, condition_key, condition_value) %}

with root_policy as (
    select policies.arn as arn, policies.content
    from {{ full_table_name("aws_organizations_policies")}} policies
        left join {{ full_table_name("aws_organizations_policy_targets")}} targets
            on targets.policy_arn = policies.arn
    where policies.name = 'organization root policy'
    and policies._cq_source_name = 'aws-root-account-govcloud'
    and targets.type = 'ROOT'
    and {{ partition_filter('policies') }}
    limit 1
)
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    '{{ title }}' as title,
    arn as identifier,
    JSON_OBJECT() as metadata,
    case when (select 1
               from unnest(JSON_QUERY_ARRAY(content, '$.Statement')) statement
               where JSON_VALUE(statement, '$.Effect') = 'Deny'
                 and JSON_VALUE(statement, '$.Condition.{{ check }}."{{ condition_key }}"') = '{{ condition_value }}'
             {% for item in blocked_actions %}
    and '{{ item }}' in UNNEST(JSON_VALUE_ARRAY(statement, '$.Action'))
    {% endfor %}
    ) = 1
    then 'pass'
    else 'fail'
end as status,
    JSON_OBJECT() as tags
from root_policy
    {% endmacro %}