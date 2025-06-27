{% macro compute_instances_with_default_service_account_with_full_access(framework, check_id) %}
  {{ return(adapter.dispatch('compute_instances_with_default_service_account_with_full_access')(framework, check_id)) }}
{% endmacro %}

{% macro default__compute_instances_with_default_service_account_with_full_access(framework, check_id) %}{% endmacro %}

{% macro bigquery__compute_instances_with_default_service_account_with_full_access(framework, check_id) %}
select
     DISTINCT
                gci.name                                                                    AS resource_id,
                '{{framework}}' As framework,
                '{{check_id}}' As check_id,                                                                         
                'Ensure that instances are not configured to use the default service account with full access to all Cloud APIs (Automated)' AS title,
                gci.project_id                                                                AS project_id,
                CASE
                    WHEN
                            JSON_VALUE(gcisa.email) = (SELECT default_service_account
                                               FROM {{ full_table_name("gcp_compute_projects") }}
                                               WHERE project_id = gci.project_id AND {{ partition_filter() }})
                            AND 'https://www.googleapis.com/auth/cloud-platform' IN UNNEST(JSON_EXTRACT_STRING_ARRAY(gcisa.scopes))
                        THEN 'fail'
                    ELSE 'pass'
                    END AS status
    FROM {{ full_table_name("gcp_compute_instances") }} gci, 
    UNNEST(JSON_QUERY_ARRAY(service_accounts)) AS gcisa
    WHERE {{ partition_filter("gci") }}
{% endmacro %}