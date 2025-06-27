{% macro partition_filter(ref=None) %}
    {%- if ref is not none -%}
        TIMESTAMP_TRUNC({{ ref }}._cq_sync_time, DAY) = TIMESTAMP(CURRENT_DATE())
    {%- else -%}
        TIMESTAMP_TRUNC(_cq_sync_time, DAY) = TIMESTAMP(CURRENT_DATE())
    {%- endif -%}
{% endmacro %}
