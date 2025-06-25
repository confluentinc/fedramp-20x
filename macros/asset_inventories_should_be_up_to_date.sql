-- depends_on: {{ ref('aws_resources') }}
-- depends_on: {{ ref('gcp_resources') }}
-- depends_on: {{ ref('k8s_resources') }}
{% macro asset_inventories_should_be_up_to_date(framework, check_id) %}
  {{ return(adapter.dispatch('asset_inventories_should_be_up_to_date')(framework, check_id)) }}
{% endmacro %}

{% macro default__asset_inventories_should_be_up_to_date(framework, check_id) %}{% endmacro %}

{% macro bigquery__asset_inventories_should_be_up_to_date(framework, check_id) %}
with inventory_list as (
  select inventory_table from unnest(['aws_resources', 'gcp_resources', 'k8s_resources']) as inventory_table
)
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Asset Inventories should be up to date' as title,
    inventory_table as identifier,
    null as metadata,
    case
        when table_name is not null
                 and DATE(creation_time) >= DATE_SUB(CURRENT_DATE(), INTERVAL 1 DAY) then 'pass'
        else 'fail'
        end as status,
    JSON_OBJECT() as tags
from inventory_list
left join {{ full_table_name("INFORMATION_SCHEMA.TABLES") }} on table_name = inventory_table
    {% endmacro %}