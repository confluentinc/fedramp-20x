{% macro logging_not_configured_across_services_and_users(framework, check_id) %}
  {{ return(adapter.dispatch('logging_not_configured_across_services_and_users')(framework, check_id)) }}
{% endmacro %}

{% macro default__logging_not_configured_across_services_and_users(framework, check_id) %}{% endmacro %}

{% macro bigquery__logging_not_configured_across_services_and_users(framework, check_id) %}
WITH project_policy_audit_configs AS (SELECT project_id,
                                             audit_config
                                      FROM {{ full_table_name("gcp_resourcemanager_project_policies") }},
                                      UNNEST(JSON_QUERY_ARRAY(audit_configs)) AS audit_config
                                       WHERE audit_configs IS NOT NULL AND {{ partition_filter() }}),
     log_types AS (SELECT
				   		  project_id,
                          JSON_VALUE(audit_config.service)  AS service,
                          logs.logType         AS logs,
                          logs.exemptedMembers AS exempted
                   FROM project_policy_audit_configs,
                   UNNEST(JSON_QUERY_ARRAY(audit_config.auditLogConfigs)) AS logs
                   ),
    valid_log_types AS (
                    SELECT project_id, service, count(*) as valid_types
                     FROM log_types
                     WHERE exempted IS NULL
                     AND JSON_VALUE(logs) IN ('ADMIN_READ', 'DATA_READ', 'DATA_WRITE')
                     AND JSON_VALUE(service) = 'allServices'
                     GROUP BY project_id, service
    )
    select DISTINCT 
                service                                                                    AS resource_id,
                '{{framework}}' As framework,
                '{{check_id}}' As check_id,                                                                         
                'Ensure that Cloud Audit Logging is configured properly across all services and all users from a project (Automated)' AS title,
                "project_id"                                                                AS project_id,
                CASE
                WHEN
                        valid_types = 3
                    THEN 'pass'
                ELSE 'fail'
                END AS status
    FROM valid_log_types
{% endmacro %}
