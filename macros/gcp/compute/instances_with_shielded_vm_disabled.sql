{% macro compute_instances_with_shielded_vm_disabled(framework, check_id) %}
  {{ return(adapter.dispatch('compute_instances_with_shielded_vm_disabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__compute_instances_with_shielded_vm_disabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__compute_instances_with_shielded_vm_disabled(framework, check_id) %}
select 
                name                                                                   AS resource_id,
                '{{framework}}' As framework,
                '{{check_id}}' As check_id,                                                                         
                'Ensure Compute instances are launched with Shielded VM enabled (Automated)' AS title,
                project_id                                                                AS project_id,
                CASE
                WHEN
                    
                    CAST( JSON_VALUE(shielded_instance_config.enable_integrity_monitoring) AS BOOL) = FALSE
                        OR CAST( JSON_VALUE(shielded_instance_config.enable_vtpm) AS BOOL) = FALSE
                        OR CAST( JSON_VALUE(shielded_instance_config.enable_secure_boot) AS BOOL) = FALSE
                    THEN 'fail'
                ELSE 'pass'
                END AS status
    FROM {{ full_table_name("gcp_compute_instances") }}
    WHERE {{ partition_filter() }}
{% endmacro %}