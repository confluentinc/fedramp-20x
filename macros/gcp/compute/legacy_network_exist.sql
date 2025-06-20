{% macro compute_legacy_network_exist(framework, check_id) %}
  {{ return(adapter.dispatch('compute_legacy_network_exist')(framework, check_id)) }}
{% endmacro %}

{% macro default__compute_legacy_network_exist(framework, check_id) %}{% endmacro %}

{% macro bigquery__compute_legacy_network_exist(framework, check_id) %}
select 
                CAST(id AS STRING)                                                                    AS resource_id,
                '{{framework}}' As framework,
                '{{check_id}}' As check_id,                                                                         
                'Ensure legacy networks do not exist for a project (Automated)' AS title,
                project_id                                                                AS project_id,
                CASE
                WHEN
                    JSON_VALUE(dnssec_config.state) != 'on'
                    THEN 'fail'
                ELSE 'pass'
                END AS status
    FROM {{ full_table_name("gcp_dns_managed_zones") }}
    WHERE {{ partition_filter() }}
{% endmacro %}