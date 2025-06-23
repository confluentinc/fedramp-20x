{% set k8s_tables %}
    {{ k8s_tables_dyn() }}
{% endset %}

{%- for row in run_query(k8s_tables) -%}
    {%- if row.table_name is not none and row.table_name != '' -%}
        {{ k8s_asset_resources(row.table_name) }}
        {%- if not loop.last -%} UNION ALL {% endif -%}
    {%- endif -%}
{%- endfor -%}