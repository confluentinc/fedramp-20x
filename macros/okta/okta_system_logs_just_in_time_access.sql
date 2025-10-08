
{% macro okta_system_logs_just_in_time_access(framework, check_id) %}
  {{ return(adapter.dispatch('okta_system_logs_just_in_time_access')(framework, check_id)) }}
{% endmacro %}

{% macro default__okta_system_logs_just_in_time_access(framework, check_id) %}{% endmacro %}

{% macro bigquery__okta_system_logs_just_in_time_access(framework, check_id) %}
with group_additions as (
  select
    event_uuid,
    JSON_VALUE(target_user, '$.id') as user_id,
    JSON_VALUE(target_user_group, '$.id') as user_group_id,
    event_time,
  from cloudquery.okta_system_log_normalized
  where event_type = 'group.user_membership.add'
  and actor_id = '{{ var("okta_jit_actor_id") }}'
  and outcome_result = 'SUCCESS'
),
group_removals as (
  select
    event_uuid,
    JSON_VALUE(target_user, '$.id') as user_id,
    JSON_VALUE(target_user_group, '$.id') as user_group_id,
    event_time,
  from cloudquery.okta_system_log_normalized
  where event_type = 'group.user_membership.remove'
  and actor_id = '{{ var("okta_jit_actor_id") }}'
  and outcome_result = 'SUCCESS'
)
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'Okta group membership managed by Just-in-time controls' as title,
    group_additions.event_uuid as identifier,
    JSON_OBJECT() as metadata,
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

{% endmacro %}
