{% macro aws_resources_should_be_managed_by_iac(framework, check_id) %}
  {{ return(adapter.dispatch('aws_resources_should_be_managed_by_iac')(framework, check_id)) }}
{% endmacro %}

{% macro default__aws_resources_should_be_managed_by_iac(framework, check_id) %}{% endmacro %}

{% macro bigquery__aws_resources_should_be_managed_by_iac(framework, check_id) %}
-- TODO: Once asset inventory models are in place, leverage those instead
{% set iac_tagging_scheme = var('iac_tagging_scheme') %}
with assets as (
  {%- for table in var('ksi_cmt_02_tables') -%}
      select arn, tags, account_id from {{ full_table_name(table) }} where {{ partition_filter() }}
    {%- if not loop.last -%}{{ union() }}{%- endif -%}
  {%- endfor -%}
)
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'AWS Resources should be managed by Infrastructure as Code' as title,
    arn as identifier,
    null as metadata,
    case when JSON_VALUE(tags, '$.{{ iac_tagging_scheme["key"] }}') IN ({{ to_sql_list(iac_tagging_scheme["values"]) }})
         then 'pass'
         else 'fail'
    end as status,
    tags
from assets
    {% endmacro %}
