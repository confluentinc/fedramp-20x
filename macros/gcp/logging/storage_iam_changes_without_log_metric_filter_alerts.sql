{% macro logging_storage_iam_changes_without_log_metric_filter_alerts(framework, check_id) %}
  {{ return(adapter.dispatch('logging_storage_iam_changes_without_log_metric_filter_alerts')(framework, check_id)) }}
{% endmacro %}

{% macro default__logging_storage_iam_changes_without_log_metric_filter_alerts(framework, check_id) %}{% endmacro %}

{% macro bigquery__logging_storage_iam_changes_without_log_metric_filter_alerts(framework, check_id) %}
select DISTINCT 
                filter                                                                    AS resource_id,
                '{{framework}}' As framework,
                '{{check_id}}' As check_id,                                                                         
                'Ensure that the log metric filter and alerts exist for Cloud Storage IAM permission changes (Automated)' AS title,
                project_id                                                                AS project_id,
                CASE
                WHEN
                            disabled = FALSE
                        AND REGEXP_CONTAINS(filter, r'\s*resource.type\s*=\s*gcs_bucket\s*AND\s*protoPayload.methodName\s*=\s*"storage.setIamPermissions"\s*')
                THEN 'fail'
                ELSE 'pass'
                END AS status
    FROM {{ full_table_name("gcp_logging_metrics") }}
    WHERE {{ partition_filter() }}
{% endmacro %}