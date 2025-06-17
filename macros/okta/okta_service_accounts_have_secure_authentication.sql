
{% macro okta_service_accounts_have_secure_authentication(framework, check_id) %}
  {{ return(adapter.dispatch('okta_service_accounts_have_secure_authentication')(framework, check_id)) }}
{% endmacro %}

{% macro default__okta_service_accounts_have_secure_authentication(framework, check_id) %}{% endmacro %}

{% macro bigquery__okta_service_accounts_have_secure_authentication(framework, check_id) %}
with password as (
    select *
    from {{ full_table_name("okta_policies") }}
    where type = "PASSWORD"
    and status = "ACTIVE"
)

select *
from {{ full_table_name("okta_users") }}
where STARTS_WITH(JSON_VALUE(profile, "$.email"), "srv_")
  and {{ partition_filter() }}

{% endmacro %}