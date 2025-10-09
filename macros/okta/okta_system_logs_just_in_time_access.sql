
{% macro okta_system_logs_just_in_time_access(framework, check_id, applications) %}
  {{ return(adapter.dispatch('okta_system_logs_just_in_time_access')(framework, check_id, applications)) }}
{% endmacro %}

{% macro default__okta_system_logs_just_in_time_access(framework, check_id, applications) %}{% endmacro %}

{% macro bigquery__okta_system_logs_just_in_time_access(framework, check_id, applications) %}

-- Given the list of applications we want to verify JIT access controls on, we have
-- to get all of the groups assigned to those applications
with app_groups as (
  select oaga.id, oaga.app_id, oa.label as app_name
  from {{ full_table_name("okta_application_group_assignments")}} oaga
  left join {{ full_table_name("okta_applications")}} oa
    on oaga.app_id = oa.id
  where app_id IN ({{ to_sql_list(applications) }})
  and {{ partition_filter("oaga") }}
),
group_additions as (
  select
    event_uuid,
    JSON_VALUE(target_user, '$.id') as user_id,
    JSON_VALUE(target_user_group, '$.id') as user_group_id,
    event_time
  from cloudquery.okta_system_log_normalized
  where event_type = 'group.user_membership.add'
  --and actor_id = '{{ var("okta_jit_actor_id") }}'
  and outcome_result = 'SUCCESS'
),
group_removals as (
  select
    event_uuid,
    JSON_VALUE(target_user, '$.id') as user_id,
    JSON_VALUE(target_user_group, '$.id') as user_group_id,
    event_time
  from cloudquery.okta_system_log_normalized
  where event_type = 'group.user_membership.remove'
  --and actor_id = '{{ var("okta_jit_actor_id") }}'
  and outcome_result = 'SUCCESS'
)
{% for application in applications %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'Okta group membership for {{ application }} managed by Just-in-time controls' as title,
    group_additions.event_uuid as identifier,
    JSON_OBJECT("application", app_groups.app_name) as metadata,
    CASE
        WHEN group_removals.event_uuid IS NOT NULL
        THEN 'pass'
        ELSE 'fail'
END as status,
    JSON_OBJECT() as tags
from group_additions
left join group_removals
    on group_removals.user_id = group_additions.user_id
    and group_removals.user_group_id = group_additions.user_group_id
    and group_removals.event_time BETWEEN group_additions.event_time and TIMESTAMP_ADD(group_additions.event_time, INTERVAL 10 HOUR)
left join app_groups ON group_additions.user_group_id = app_groups.id and app_groups.app_id = '{{ application }}'
where group_additions.user_group_id IN (select id from app_groups where app_id = '{{ application }}')
{% if not loop.last %}UNION ALL{% endif %}
{% endfor %}
{% endmacro %}
