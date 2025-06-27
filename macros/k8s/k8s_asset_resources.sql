{% macro k8s_asset_resources(table_name) %}
  {{ return(adapter.dispatch('k8s_asset_resources')(table_name)) }}
{% endmacro %}

{%- macro bigquery__k8s_asset_resources(table_name) -%}
SELECT 
    _cq_id,
    _cq_source_name,
    _cq_sync_time,
    context,
    kind,
    api_version,
    namespace,
    name,
  '{{ table_name | string }}' AS _cq_table
FROM {{ full_table_name(table_name | string) }}
WHERE {{ partition_filter() }}
{%- endmacro -%}  
