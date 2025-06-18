{% macro distribution_should_not_use_depricated_ssl_protocols(framework, check_id) %}
  {{ return(adapter.dispatch('distribution_should_not_use_depricated_ssl_protocols')(framework, check_id)) }}
{% endmacro %}

{% macro default__distribution_should_not_use_depricated_ssl_protocols(framework, check_id) %}{% endmacro %}

{% macro bigquery__distribution_should_not_use_depricated_ssl_protocols(framework, check_id) %}
WITH origins_with_sslv3 AS (
SELECT DISTINCT
    arn,
    JSON_VALUE(o.Id) AS origin_id
FROM
    {{ full_table_name("aws_cloudfront_distributions") }},
    UNNEST(JSON_QUERY_ARRAY(distribution_config.Origins.Items)) AS o
WHERE
    'SSLv3' IN UNNEST(JSON_EXTRACT_STRING_ARRAY(o.CustomOriginConfig.OriginSslProtocols.Items))
)
SELECT
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'CloudFront distributions should not use deprecated SSL protocols between edge locations and custom origins' as title,
    d.account_id,
    d.arn as resource_id,
    CASE
        WHEN o.arn is null THEN 'pass'
        ELSE 'fail'
    END as status
FROM
            {{ full_table_name("aws_cloudfront_distributions") }} d
    LEFT JOIN origins_with_sslv3 o
    ON d.arn = o.arn
WHERE {{ partition_filter("d") }}
{% endmacro %}
