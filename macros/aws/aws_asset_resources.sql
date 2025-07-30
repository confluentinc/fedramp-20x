{% macro aws_asset_resources(table_name, ARN_EXIST, ACCOUNT_ID_EXIST, REQUEST_ACCOUNT_ID_EXIST, REGION_EXIST, TAGS_EXIST) %}
  {{ return(adapter.dispatch('aws_asset_resources')(table_name, ARN_EXIST, ACCOUNT_ID_EXIST, REQUEST_ACCOUNT_ID_EXIST, REGION_EXIST, TAGS_EXIST)) }}
{% endmacro %}

{%- macro bigquery__aws_asset_resources(table_name, ARN_EXIST, ACCOUNT_ID_EXIST, REQUEST_ACCOUNT_ID_EXIST, REGION_EXIST, TAGS_EXIST) -%}
SELECT 
_cq_id, _cq_source_name, _cq_sync_time,
  {% if ACCOUNT_ID_EXIST %}
    account_id
  {% else %}
    SPLIT(arn, ':')[SAFE_OFFSET(4)]
  {% endif %} AS account_id,
  {% if REQUEST_ACCOUNT_ID_EXIST %}
    request_account_id
  {% else %}
    SPLIT(arn, ':')[SAFE_OFFSET(4)]
  {% endif %} AS request_account_id,
    CASE WHEN SPLIT(SPLIT(arn, ':')[SAFE_OFFSET(5)], '/')[SAFE_OFFSET(1)] IS NULL AND SPLIT(arn, ':')[SAFE_OFFSET(6)] IS NULL
    THEN NULL
    ELSE SPLIT(SPLIT(arn, ':')[SAFE_OFFSET(5)], '/')[SAFE_OFFSET(0)] END AS TYPE,
    arn,
  {% if REGION_EXIST %}
    region
  {% else %}
    'unavailable'
  {% endif %} AS region,
  {% if TAGS_EXIST %}
    TO_JSON_STRING(tags)
  {% else %}
    TO_JSON_STRING(STRUCT())
  {% endif %} AS tags,
  SPLIT(arn, ':')[SAFE_OFFSET(1)] AS PARTITIONS,
  SPLIT(arn, ':')[SAFE_OFFSET(2)] AS service,
  '{{ table_name | string }}' AS _cq_table,
  {% if TAGS_EXIST %}
     {% for key, value in var('aws_resources_tag_mapping', default={}).items() %}
        JSON_EXTRACT_SCALAR(tags, '$.{{ key }}') AS {{ value }}{%- if not loop.last -%},{%- endif -%}
     {% endfor %}
  {% else %}
    {% for key, value in var('aws_resources_tag_mapping', default={}).items() %}
        NULL AS {{ value }}{%- if not loop.last -%},{%- endif -%}
     {% endfor %}
  {% endif %}
FROM {{ full_table_name(table_name | string) }}
WHERE {{ partition_filter() }}
{%- endmacro -%}  
