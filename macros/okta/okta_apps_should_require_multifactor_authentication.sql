{% macro okta_apps_should_require_multifactor_authentication(framework, check_id) %}
  {{ return(adapter.dispatch('okta_apps_should_require_multifactor_authentication')(framework, check_id)) }}
{% endmacro %}

{% macro default__okta_apps_should_require_multifactor_authentication(framework, check_id) %}{% endmacro %}

{% macro bigquery__okta_apps_should_require_multifactor_authentication(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Applications should require Multi Factor Authentication' as title,
    image_name as identifier,
    null as metadata,
    case when er.repository_uri IS NOT NULL and er.image_tag_mutability = 'IMMUTABLE'
         then 'pass'
         else 'fail'
    end as status,
    tags
from {{ full_table_name("okta_applications") }} as app
left join {{ full_table_name("okta_policies") }} as policy
on REGEXP_EXTRACT(JSON_VALUE(_links, "$.accessPolicy.href"), r'/([^/]+)/?$') = policy.id
where app.status = 'ACTIVE'

{% endmacro %}