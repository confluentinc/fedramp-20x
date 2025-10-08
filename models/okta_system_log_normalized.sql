select
    JSON_VALUE(actor, '$.alternateId') as actor_alternate_id,
    JSON_VALUE(actor, '$.displayName') as actor_display_name,
    JSON_VALUE(actor, '$.id') as actor_id,
    JSON_VALUE(actor, '$.type') as actor_type,
    display_message,
    event_type,
    JSON_VALUE(outcome, '$.result') as outcome_result,
    JSON_VALUE(outcome, '$.reason') as outcome_reason,
    published as event_time,
    uuid as event_uuid,
    (
        select * from unnest(JSON_QUERY_ARRAY(target)) as item where JSON_VALUE(item, '$.type') = 'AppUser' limit 1
    ) as target_app_user,
    (
        select * from unnest(JSON_QUERY_ARRAY(target)) as item where JSON_VALUE(item, '$.type') = 'AppInstance' limit 1
    ) as target_app_instance,
    (
        select * from unnest(JSON_QUERY_ARRAY(target)) as item where JSON_VALUE(item, '$.type') = 'User' limit 1
    ) as target_user,
    (
        select * from unnest(JSON_QUERY_ARRAY(target)) as item where JSON_VALUE(item, '$.type') = 'UserGroup' limit 1
    ) as target_user_group
from {{ full_table_name("okta_system_log_events")}}
where {{ partition_filter() }}
