
{% macro vendors_should_have_fedramp_authorization(framework, check_id) %}
  {{ return(adapter.dispatch('vendors_should_have_fedramp_authorization')(framework, check_id)) }}
{% endmacro %}

{% macro default__vendors_should_have_fedramp_authorization(framework, check_id) %}{% endmacro %}

{% macro bigquery__vendors_should_have_fedramp_authorization(framework, check_id) %}
with vendor_list as (
  select vendor from unnest([{{ to_sql_list(var('third_party_vendors')) }}]) as vendor
)
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Vendors should have FedRAMP authorization' as title,
    vendor as identifier,
    null as metadata,
    case
        when exists (
            select 1 from {{ full_table_name("fedramp_marketplace") }}
                     where `Cloud Service Offering` = vendor
                     and Status = 'FedRAMP Authorized'
            ) then 'pass'
        else 'fail'
    end as status,
    JSON_OBJECT() as tags
from vendor_list
    {% endmacro %}
