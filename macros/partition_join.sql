{% macro partition_join(left, right) %}
    TIMESTAMP_TRUNC({{ left }}._cq_sync_time, DAY) = TIMESTAMP_TRUNC({{ right }}._cq_sync_time, DAY)
{% endmacro %}
