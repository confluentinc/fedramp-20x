{% macro k8s_tables_dyn() %}
  {{ return(adapter.dispatch('k8s_tables_dyn')()) }}
{% endmacro %}

{% macro bigquery__k8s_tables_dyn() %}

SELECT 
    t.table_name,
FROM 
    {{ full_table_name("INFORMATION_SCHEMA.TABLES") }} t
INNER JOIN 
    {{ full_table_name("INFORMATION_SCHEMA.COLUMNS") }} c ON t.table_name = c.table_name AND t.table_schema = c.table_schema
WHERE
    t.table_type = 'BASE TABLE'
AND t.table_name LIKE 'k8s_%s'
AND t.table_name NOT IN ('k8s_resources', 'k8s_container_images')
AND t.table_name NOT LIKE 'k8s_compliance__%'
GROUP BY 
    t.table_name
{% endmacro %}
