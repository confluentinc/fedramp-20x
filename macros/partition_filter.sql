{% macro partition_filter() %}
    TIMESTAMP_TRUNC(_cq_sync_time, DAY) = TIMESTAMP(CURRENT_DATE())
{% endmacro %}
