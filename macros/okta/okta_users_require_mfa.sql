{% macro okta_users_require_mfa(framework, check_id) %}
  {{ return(adapter.dispatch('okta_users_require_mfa')(framework, check_id)) }}
{% endmacro %}

{% macro default__okta_users_require_mfa(framework, check_id) %}{% endmacro %}

{% macro bigquery__okta_users_require_mfa(framework, check_id) %}
with policies_that_require_mfa as (
    select p.*
    from {{ full_table_name("okta_policy_rules") }} as pr
        left join {{ full_table_name("okta_policies") }} as p
    on pr._cq_parent_id = p._cq_id
    where p.type = 'OKTA_SIGN_ON'
      and JSON_VALUE(pr.additional_properties, "$.actions.signon.requireFactor") = "true"
      and p.status = 'ACTIVE'
      and {{ partition_filter("pr") }}
),
mfa_required_groups as (
    select STRING(group_id) as group_id
  from policies_that_require_mfa,
  unnest(JSON_QUERY_ARRAY(additional_properties, "$.conditions.people.groups.include")) as group_id
),
user_groups as (
    select group_user.id as user_id, mfa_group.group_id from {{ full_table_name("okta_group_users") }} as group_user
    right join mfa_required_groups as mfa_group
    on group_user.group_id = mfa_group.group_id
    where mfa_group.group_id IS NOT NULL
)
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Users require Multi Factor Authentication to sign in' as title,
    JSON_VALUE(user.profile, "$.email") as identifier,
    JSON_OBJECT() as metadata,
    case when exists (select * from user_groups where user_id = user.id limit 1)
        then 'pass'
        else 'fail'
    end as status,
    JSON_OBJECT() as tags
from {{ full_table_name("okta_users") }} as user
where JSON_VALUE(profile, "$.serviceAccount") IS DISTINCT FROM "true"
and {{ partition_filter("user") }}

{% endmacro %}