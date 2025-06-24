{% macro bigquery_datasets_publicly_accessible(framework, check_id) %}
  {{ return(adapter.dispatch('bigquery_datasets_publicly_accessible')(framework, check_id)) }}
{% endmacro %}

{% macro default__bigquery_datasets_publicly_accessible(framework, check_id) %}{% endmacro %}

{% macro bigquery__bigquery_datasets_publicly_accessible(framework, check_id) %}
 select DISTINCT 
                d.id                                                                                   AS resource_id,
                '{{framework}}' As framework,
                '{{check_id}}' As check_id,                                                                         
                'Ensure that BigQuery datasets are not anonymously or publicly accessible (Automated)' AS title,
                d.project_id                                                                           AS project_id,
                CASE
                    WHEN
                                JSON_VALUE(a.role) = 'allUsers'
                            OR JSON_VALUE(a.role) = 'allAuthenticatedUsers'
                        THEN 'fail'
                    ELSE 'pass'
                    END                                                                                AS status
FROM {{ full_table_name("gcp_bigquery_datasets") }} d,
UNNEST(JSON_QUERY_ARRAY(access)) AS a
WHERE {{ partition_filter("d") }}
{% endmacro %}