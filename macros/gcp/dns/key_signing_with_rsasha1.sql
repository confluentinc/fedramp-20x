{% macro dns_key_signing_with_rsasha1(framework, check_id) %}
  {{ return(adapter.dispatch('dns_key_signing_with_rsasha1')(framework, check_id)) }}
{% endmacro %}

{% macro default__dns_key_signing_with_rsasha1(framework, check_id) %}{% endmacro %}

{% macro bigquery__dns_key_signing_with_rsasha1(framework, check_id) %}
select
    DISTINCT 
                CAST(gdmz.id AS STRING)                                                                           AS resource_id,
                '{{framework}}' As framework,
                '{{check_id}}' As check_id,                                                                         
                'Ensure that DNSSEC is enabled for Cloud DNS (Automated)' AS title,
                gdmz.project_id                                                                             AS project_id,
                CASE
                    WHEN
                                JSON_VALUE(gdmzdcdks.keyType) = 'keySigning'
                            AND JSON_VALUE(gdmzdcdks.algorithm) = 'rsasha1'
                        THEN 'fail'
                    ELSE 'pass'
                    END AS status
    FROM {{ full_table_name("gcp_dns_managed_zones") }} gdmz,
    UNNEST(JSON_QUERY_ARRAY(gdmz.dnssec_config.defaultKeySpecs)) AS gdmzdcdks
    WHERE {{ partition_filter("gdmz") }}
{% endmacro %}