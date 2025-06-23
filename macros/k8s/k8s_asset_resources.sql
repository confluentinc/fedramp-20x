{% macro k8s_asset_resources(table_name, ARN_EXIST, ACCOUNT_ID_EXIST, REQUEST_ACCOUNT_ID_EXIST, REGION_EXIST, TAGS_EXIST) %}
  {{ return(adapter.dispatch('k8s_asset_resources')(table_name, ARN_EXIST, ACCOUNT_ID_EXIST, REQUEST_ACCOUNT_ID_EXIST, REGION_EXIST, TAGS_EXIST)) }}
{% endmacro %}

{%- macro bigquery__k8s_asset_resources(table_name, ARN_EXIST, ACCOUNT_ID_EXIST, REQUEST_ACCOUNT_ID_EXIST, REGION_EXIST, TAGS_EXIST) -%}
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
