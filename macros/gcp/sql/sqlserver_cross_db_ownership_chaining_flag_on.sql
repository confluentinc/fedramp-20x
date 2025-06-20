{% macro sql_sqlserver_cross_db_ownership_chaining_flag_on(framework, check_id) %}
  {{ return(adapter.dispatch('sql_sqlserver_cross_db_ownership_chaining_flag_on')(framework, check_id)) }}
{% endmacro %}

{% macro default__sql_sqlserver_cross_db_ownership_chaining_flag_on(framework, check_id) %}{% endmacro %}

{% macro bigquery__sql_sqlserver_cross_db_ownership_chaining_flag_on(framework, check_id) %}
WITH 
    instance_flags as (
    select
        f as value
    FROM {{ full_table_name("gcp_sql_instances") }} gsi,
    UNNEST(JSON_QUERY_ARRAY(settings.databaseFlags)) AS f
    WHERE {{ partition_filter('gsi') }}
    )

select
                gsi.name                                                                    AS resource_id,
                '{{framework}}' As framework,
                '{{check_id}}' As check_id,                                                                         
                'Ensure that the "cross db ownership chaining" database flag for Cloud SQL SQL Server instance is set to "off" (Automated)' AS title,
                gsi.project_id                                                                AS project_id,
                CASE
                WHEN
                            gsi.database_version LIKE 'SQLSERVER%'
                        AND (f.value.value IS NULL
                        OR JSON_VALUE(f.value.value) != 'off')
                    THEN 'fail'
                ELSE 'pass'
                END AS status
    FROM {{ full_table_name("gcp_sql_instances") }} gsi
    LEFT JOIN 
    instance_flags AS f ON JSON_VALUE(f.value.name) ='cross db ownership chaining'
    WHERE {{ partition_filter('gsi') }}
{% endmacro %}