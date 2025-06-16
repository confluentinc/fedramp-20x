{% macro to_sql_list(list_variable) %}
    {%- for item in list_variable -%}
        '{{ item }}'
        {%- if not loop.last -%}, {%- endif -%}
    {%- endfor -%}
{% endmacro %}