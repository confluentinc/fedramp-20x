{% macro logging_dns_logging_disabled(framework, check_id) %}
  {{ return(adapter.dispatch('logging_dns_logging_disabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__logging_dns_logging_disabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__logging_dns_logging_disabled(framework, check_id) %}
select DISTINCT 
                gcn.name                                                                    AS resource_id,
                '{{framework}}' As framework,
                '{{check_id}}' As check_id,                                                                         
                'Ensure that Cloud DNS logging is enabled for all VPC networks (Automated)' AS title,
                gcn.project_id                                                                AS project_id,
                CASE
                    WHEN
                        gdp.enable_logging = FALSE
                        THEN 'fail'
                    ELSE 'pass'
                    END                                                                     AS status
    FROM {{ full_table_name("gcp_dns_policies") }} gdp,
    UNNEST(JSON_QUERY_ARRAY(gdp.networks)) AS gdpn
    JOIN {{ full_table_name("gcp_compute_networks") }} gcn
        ON gcn.self_link = REPLACE(JSON_VALUE(gdpn.networkUrl), 'compute.googleapis', 'www.googleapis')
        AND {{ partition_join("gcn", "gdp")}}
    WHERE {{ partition_filter("gdp") }}
{% endmacro %}