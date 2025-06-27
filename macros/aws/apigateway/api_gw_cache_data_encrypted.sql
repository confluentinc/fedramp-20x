{% macro api_gw_cache_data_encrypted(framework, check_id) %}
  {{ return(adapter.dispatch('api_gw_cache_data_encrypted')(framework, check_id)) }}
{% endmacro %}

{% macro default__api_gw_cache_data_encrypted(framework, check_id) %}{% endmacro %}

{% macro bigquery__api_gw_cache_data_encrypted(framework, check_id) %}
with bad_methods as (
select DISTINCT
    arn
from {{ full_table_name("aws_apigateway_rest_api_stages") }} as s,
    UNNEST(JSON_QUERY_ARRAY(s.method_settings)) AS ms
  WHERE
    JSON_VALUE(ms.CachingEnabled) = 'true'
    AND
    JSON_VALUE(ms.CacheDataEncrypted) <> 'true'
    and {{ partition_filter("s") }}
),
cache_enabled AS (
select DISTINCT
    arn,
    account_id
FROM  {{ full_table_name("aws_apigateway_rest_api_stages") }} as s,
UNNEST(JSON_QUERY_ARRAY(s.method_settings)) AS ms
WHERE
    JSON_VALUE(ms.CachingEnabled) = 'true'
AND {{ partition_filter("s") }}
)
SELECT
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'API Gateway REST API cache data should be encrypted at rest' as title,
    ce.account_id,
    ce.arn as resource_id,
    CASE
        WHEN b.arn is not null THEN 'fail'
        ELSE 'pass'
    END as status
FROM 
    cache_enabled ce
    LEFT JOIN bad_methods as b
        ON ce.arn = b.arn
{% endmacro %}
