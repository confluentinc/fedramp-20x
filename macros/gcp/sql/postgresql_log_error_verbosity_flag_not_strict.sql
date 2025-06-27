{% macro sql_postgresql_log_error_verbosity_flag_not_strict(framework, check_id) %}
  {{ return(adapter.dispatch('sql_postgresql_log_error_verbosity_flag_not_strict')(framework, check_id)) }}
{% endmacro %}

{% macro default__sql_postgresql_log_error_verbosity_flag_not_strict(framework, check_id) %}{% endmacro %}

{% macro bigquery__sql_postgresql_log_error_verbosity_flag_not_strict(framework, check_id) %}
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
                'Ensure "log_error_verbosity" database flag for Cloud SQL PostgreSQL instance is set to "DEFAULT" or stricter (Manual)' AS title,
                gsi.project_id                                                                AS project_id,
                CASE
                WHEN
                            gsi.database_version LIKE 'POSTGRES%'
                        AND (f.value.value IS NULL
                        OR JSON_VALUE(f.value.value) NOT IN ('default', 'terse'))
                    THEN 'fail'
                ELSE 'pass'
                END AS status
    FROM {{ full_table_name("gcp_sql_instances") }} gsi
    LEFT JOIN 
    instance_flags AS f ON JSON_VALUE(f.value.name) ='log_error_verbosity'
    WHERE {{ partition_filter('gsi') }}
{% endmacro %}