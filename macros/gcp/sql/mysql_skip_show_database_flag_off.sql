{% macro sql_mysql_skip_show_database_flag_off(framework, check_id) %}
  {{ return(adapter.dispatch('sql_mysql_skip_show_database_flag_off')(framework, check_id)) }}
{% endmacro %}

{% macro default__sql_mysql_skip_show_database_flag_off(framework, check_id) %}{% endmacro %}

{% macro bigquery__sql_mysql_skip_show_database_flag_off(framework, check_id) %}
 WITH 
    instance_flags as (
    select
        f as value             
    FROM {{ full_table_name("gcp_sql_instances") }} gsi,
    UNNEST(JSON_QUERY_ARRAY(settings.databaseFlags)) AS f
    where {{ partition_filter('gsi') }}
    )

select
                gsi.name                                                                    AS resource_id,
                '{{framework}}' As framework,
                '{{check_id}}' As check_id,                                                                         
                'Ensure "skip_show_database" database flag for Cloud SQL Mysql instance is set to "on" (Automated)' AS title,
                gsi.project_id                                                                AS project_id,
                CASE
                WHEN
                            gsi.database_version LIKE 'MYSQL%'
                        AND (f.value.value IS NULL
                        OR JSON_VALUE(f.value.value) != 'on')
                    THEN 'fail'
                ELSE 'pass'
                END AS status
    FROM {{ full_table_name("gcp_sql_instances") }} gsi
    LEFT JOIN 
    instance_flags AS f ON JSON_VALUE(f.value.name) ='skip_show_database'
    WHERE {{ partition_filter('gsi') }}
{% endmacro %}