{% macro okta_users_should_not_be_manually_created(framework, check_id) %}
  {{ return(adapter.dispatch('okta_users_should_not_be_manually_created')(framework, check_id)) }}
{% endmacro %}

{% macro default__okta_users_should_not_be_manually_created(framework, check_id) %}{% endmacro %}

{% macro bigquery__okta_users_should_not_be_manually_created(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    CONCAT('Okta IdP users should not be manually created') as title,
    JSON_VALUE(target_user, '$.id') as identifier,
    JSON_OBJECT() as metadata,
    case when actor_type = 'User'
        then 'pass'
        else 'fail'
    end as status,
    JSON_OBJECT() as tags
from {{ full_table_name("okta_system_log_normalized") }}
where event_type = 'user.lifecycle.create'
    {% endmacro %}