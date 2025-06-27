{% macro api_gateway_method_settings() %}
  {{ return(adapter.dispatch('api_gateway_method_settings')()) }}
{% endmacro %}

{% macro default__api_gateway_method_settings() %}{% endmacro %}

{% macro bigquery__api_gateway_method_settings() %}
SELECT
    s.arn,
    s.rest_api_arn,
    s.stage_name,
    s.tracing_enabled AS stage_data_trace_enabled,
    s.cache_cluster_enabled AS stage_caching_enabled,
    s.web_acl_arn AS waf,
    s.client_certificate_id AS cert,
    ms.key AS method,
    CASE WHEN CAST(JSON_VALUE(ms.DataTraceEnabled) AS STRING) = 'true' THEN 1 ELSE 0 END AS data_trace_enabled,
    CASE WHEN CAST(JSON_VALUE(ms.CachingEnabled) AS STRING) = 'true' THEN 1 ELSE 0 END AS caching_enabled,
    CASE WHEN CAST(JSON_VALUE(ms.CacheDataEncrypted) AS STRING) = 'true' THEN 1 ELSE 0 END AS cache_data_encrypted,
    CAST(JSON_VALUE(ms.LoggingLevel) AS STRING) AS logging_level,
    r.account_id
FROM {{ full_table_name("aws_apigateway_rest_api_stages") }} s
JOIN {{ full_table_name("aws_apigateway_rest_apis") }} r ON s.rest_api_arn=r.arn,
UNNEST(JSON_QUERY_ARRAY(s.method_settings)) AS ms
WHERE {{ partition_filter("s") }}
{% endmacro %}
