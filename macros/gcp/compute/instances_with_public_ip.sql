{% macro compute_instances_with_public_ip(framework, check_id) %}
  {{ return(adapter.dispatch('compute_instances_with_public_ip')(framework, check_id)) }}
{% endmacro %}

{% macro default__compute_instances_with_public_ip(framework, check_id) %}{% endmacro %}

{% macro bigquery__compute_instances_with_public_ip(framework, check_id) %}
WITH 
    ni as (
    select
      ni as value          
    FROM {{ full_table_name("gcp_compute_instances") }} gci,
    UNNEST(JSON_QUERY_ARRAY(network_interfaces)) AS ni
    WHERE {{ partition_filter("gci") }}
    ),
    ac4 as (
    select
      ac4 as value          
    FROM ni,
    UNNEST(JSON_QUERY_ARRAY(value.access_configs)) AS ac4
      ),
    ac6 as (
    select
      ac6.value as value          
    FROM ni,
    UNNEST(JSON_QUERY_ARRAY(value.ipv6_access_configs)) AS ac6
    )    
select
    DISTINCT 
                gci.name                                                                    AS resource_id,
                '{{framework}}' As framework,
                '{{check_id}}' As check_id,                                                                         
                'Ensure that Compute instances do not have public IP addresses (Automated' AS title,
                gci.project_id                                                                AS project_id,
                CASE
                    WHEN
                                gci.name NOT LIKE 'gke-%'
                            AND (ac4.value.nat_i_p IS NOT NULL OR JSON_VALUE(ac4.value.nat_i_p) != '' OR ac6.value.nat_i_p IS NOT NULL OR JSON_VALUE(ac6.value.nat_i_p) != '')
                        THEN 'fail'
                    ELSE 'pass'
                    END                                                                    AS status
    FROM {{ full_table_name("gcp_compute_instances") }} gci
    LEFT JOIN ac4 ON TRUE
    LEFT JOIN ac6 ON TRUE
    WHERE {{ partition_filter("gci") }}
{% endmacro %}