{% macro compute_flow_logs_disabled_in_vpc(framework, check_id) %}
  {{ return(adapter.dispatch('compute_flow_logs_disabled_in_vpc')(framework, check_id)) }}
{% endmacro %}

{% macro default__compute_flow_logs_disabled_in_vpc(framework, check_id) %}{% endmacro %}

{% macro bigquery__compute_flow_logs_disabled_in_vpc(framework, check_id) %}
select
    DISTINCT 
                gcn.name                                                                    AS resource_id,
                '{{framework}}' As framework,
                '{{check_id}}' As check_id,                                                                         
                'Ensure that VPC Flow Logs is enabled for every subnet in a VPC Network (Automated)' AS title,
                gcn.project_id                                                                AS project_id,
                CASE
                    WHEN
                        gcs.enable_flow_logs = FALSE
                        THEN 'fail'
                    ELSE 'pass'
                    END AS status
    FROM {{ full_table_name("gcp_compute_networks") }} gcn
            JOIN {{ full_table_name("gcp_compute_subnetworks") }}
            gcs ON gcn.self_link = gcs.network AND {{ partition_join("gcn", "gcs") }}
    WHERE {{ partition_filter("gcn") }}
{% endmacro %}