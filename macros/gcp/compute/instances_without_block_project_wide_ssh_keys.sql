{% macro compute_instances_without_block_project_wide_ssh_keys(framework, check_id) %}
  {{ return(adapter.dispatch('compute_instances_without_block_project_wide_ssh_keys')(framework, check_id)) }}
{% endmacro %}

{% macro default__compute_instances_without_block_project_wide_ssh_keys(framework, check_id) %}{% endmacro %}

{% macro bigquery__compute_instances_without_block_project_wide_ssh_keys(framework, check_id) %}
WITH 
    metadata as (
    select
        gcmi as value
    FROM {{ full_table_name("gcp_compute_instances") }} gci,
    UNNEST(JSON_QUERY_ARRAY(metadata.items)) AS gcmi
    WHERE {{ partition_filter("gci") }}
    )

select 
                gci.name                                                                   AS resource_id,
                '{{framework}}' As framework,
                '{{check_id}}' As check_id,                                                                         
                'Ensure "Block Project-wide SSH keys" is enabled for VM instances (Automated)' AS title,
                gci.project_id                                                                AS project_id,
                CASE
                WHEN
                        gcmi.value.key IS NULL OR
                        NOT JSON_VALUE(gcmi.value.value) IN ('1', 'true', 'True', 'TRUE', 'y', 'yes')
                    THEN 'fail'
                ELSE 'pass'
                END AS status
    FROM {{ full_table_name("gcp_compute_instances") }} gci
    LEFT JOIN 
    metadata AS gcmi ON JSON_VALUE(gcmi.value.key) ='block-project-ssh-keys'
    WHERE {{ partition_filter("gci") }}
{% endmacro %}