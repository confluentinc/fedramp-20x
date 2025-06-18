{% macro okta_apps_should_require_multifactor_authentication(framework, check_id) %}
  {{ return(adapter.dispatch('okta_apps_should_require_multifactor_authentication')(framework, check_id)) }}
{% endmacro %}

{% macro default__okta_apps_should_require_multifactor_authentication(framework, check_id) %}{% endmacro %}

{% macro bigquery__okta_apps_should_require_multifactor_authentication(framework, check_id) %}

with policies_that_require_mfa as (
    select DISTINCT(p.id)
    from {{ full_table_name("okta_policy_rules") }} as pr
        left join {{ full_table_name("okta_policies") }} as p
    on pr._cq_parent_id = p._cq_id
    where pr.type = 'ACCESS_POLICY'
      and EXISTS (
        SELECT 1
        FROM UNNEST(JSON_QUERY_ARRAY(pr.additional_properties, "$.actions.appSignOn.verificationMethod.constraints")) AS authConstraint
        WHERE JSON_VALUE(authConstraint, "$.possession.phishingResistant") = 'REQUIRED'
        )
      and p.status = 'ACTIVE'
      and {{ partition_filter("pr") }}
)
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Applications should require Multi Factor Authentication' as title,
    app.label as identifier,
    null as metadata,
    case when policy.id IS NOT NULL
             then 'pass'
         else 'fail'
        end as status,
    JSON_OBJECT() as tags
from {{ full_table_name("okta_applications") }} as app
left join policies_that_require_mfa as policy ON REGEXP_EXTRACT(JSON_VALUE(app._links, "$.accessPolicy.href"), r'/([^/]+)/?$') = policy.id
where app.status = 'ACTIVE' and {{ partition_filter("app") }}

{% endmacro %}