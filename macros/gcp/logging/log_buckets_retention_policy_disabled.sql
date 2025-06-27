{% macro logging_log_buckets_retention_policy_disabled(framework, check_id) %}
  {{ return(adapter.dispatch('logging_log_buckets_retention_policy_disabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__logging_log_buckets_retention_policy_disabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__logging_log_buckets_retention_policy_disabled(framework, check_id) %}
select DISTINCT 
                gsb.name                                                                    AS resource_id,
                '{{framework}}' As framework,
                '{{check_id}}' As check_id,                                                                         
                'Ensure that retention policies on log buckets are configured using Bucket Lock (Automated)' AS title,
                gsb.project_id                                                                AS project_id,
                CASE
                    WHEN
                                gls.destination LIKE ('storage.googleapis.com/%')
                            AND (CAST(JSON_VALUE(gsb.retention_policy.IsLocked) AS BOOL) = FALSE
                            OR (CAST(JSON_VALUE(gsb.retention_policy.RetentionPeriod) AS INT64) = 0))
                        THEN 'fail'
                    ELSE 'pass'
                    END AS status
    FROM {{ full_table_name("gcp_logging_sinks") }} gls
            JOIN {{ full_table_name("gcp_storage_buckets") }} gsb ON
        gsb.name = REPLACE(gls.destination, 'storage.googleapis.com/', '')
        AND {{ partition_join("gsb", "gls") }}
    WHERE {{ partition_filter("gls") }}
{% endmacro %}