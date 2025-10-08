
{% macro okta_system_logs_identifying_log_access(framework, check_id) %}
  {{ return(adapter.dispatch('okta_system_logs_identifying_log_access')(framework, check_id)) }}
{% endmacro %}

{% macro default__okta_system_logs_identifying_log_access(framework, check_id) %}{% endmacro %}

{% macro bigquery__okta_system_logs_identifying_log_access(framework, check_id) %}
with password_policies as (
    select id, additional_properties
    from {{ full_table_name("okta_policies") }}
    where type = "PASSWORD"
    and status = "ACTIVE"
    and JSON_VALUE(additional_properties, "$.settings.password.complexity.dictionary.common.exclude") = "true"
    and JSON_VALUE(additional_properties, "$.settings.password.complexity.excludeUsername") = "true"
    and INT64(JSON_QUERY(additional_properties, "$.settings.password.complexity.minLength")) >= 15
    and INT64(JSON_QUERY(additional_properties, "$.settings.password.complexity.minLowerCase")) >= 1
    and INT64(JSON_QUERY(additional_properties, "$.settings.password.complexity.minUpperCase")) >= 1
    and INT64(JSON_QUERY(additional_properties, "$.settings.password.complexity.minNumber")) >= 1
    and INT64(JSON_QUERY(additional_properties, "$.settings.password.complexity.minSymbol")) >= 1
    and {{ partition_filter() }}
),
groups_that_require_password as (
       select STRING(group_id) as group_id, password_policies.id as policy_id, additional_properties as policy
       from password_policies,
       unnest(JSON_QUERY_ARRAY(additional_properties, "$.conditions.people.groups.include")) as group_id
),
user_groups as (
    select group_user.id as user_id, mfa_group.group_id from {{ full_table_name("okta_group_users") }} as group_user
    right join groups_that_require_password as mfa_group
    on group_user.group_id = mfa_group.group_id
    where mfa_group.group_id IS NOT NULL
)
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Service Accounts require secure authentication' as title,
    JSON_VALUE(user.profile, "$.email") as identifier,
    JSON_OBJECT() as metadata,
    case when exists (select * from user_groups where user_id = user.id limit 1)
             then 'pass'
         else 'fail'
        end as status,
    JSON_OBJECT() as tags
from {{ full_table_name("okta_users") }} as user
where JSON_VALUE(profile, "$.serviceAccount") = "true"
  and {{ partition_filter("user") }}

    {% endmacro %}
