{% macro compute_oslogin_disabled(framework, check_id) %}
  {{ return(adapter.dispatch('compute_oslogin_disabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__compute_oslogin_disabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__compute_oslogin_disabled(framework, check_id) %}
WITH 
    metadata as (
    select
        cimd as value             
    FROM {{ full_table_name("gcp_compute_projects") }},
    UNNEST(JSON_QUERY_ARRAY(common_instance_metadata.items)) AS cimd
    WHERE {{ partition_filter("gcp_compute_projects") }}
    )

select 
                name                                                                   AS resource_id,
                '{{framework}}' As framework,
                '{{check_id}}' As check_id,                                                                         
                'Ensure oslogin is enabled for a Project (Automated)' AS title,
                project_id                                                                AS project_id,
                CASE
           WHEN
               cimd.value.key IS NULL OR
               NOT JSON_VALUE(cimd.value.value) IN ('1', 'true', 'True', 'TRUE', 'y', 'yes')
               THEN 'fail'
           ELSE 'pass'
           END AS status
    FROM {{ full_table_name("gcp_compute_projects") }}
    LEFT JOIN 
    metadata AS cimd ON JSON_VALUE(cimd.value.key) ='enable-oslogin'
    WHERE {{ partition_filter("gcp_compute_projects") }}
{% endmacro %}