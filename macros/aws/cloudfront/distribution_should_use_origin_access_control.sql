{% macro distribution_should_use_origin_access_control(framework, check_id) %}
  {{ return(adapter.dispatch('distribution_should_use_origin_access_control')(framework, check_id)) }}
{% endmacro %}

{% macro default__distribution_should_use_origin_access_control(framework, check_id) %}{% endmacro %}

{% macro bigquery__distribution_should_use_origin_access_control(framework, check_id) %}
WITH s3_origins AS (
    SELECT DISTINCT
        arn,
        JSON_VALUE(o.DomainName) AS s3_domain_name,
        CAST(JSON_VALUE(o.OriginAccessControlId) AS STRING) AS origin_access_control_id
    FROM
        {{ full_table_name("aws_cloudfront_distributions") }},
        UNNEST(JSON_QUERY_ARRAY(distribution_config.Origins.Items)) AS o
    WHERE
        o.S3OriginConfig IS NOT NULL
        AND JSON_VALUE(o.DomainName) LIKE '%.s3.%'
        AND {{ partition_filter("aws_cloudfront_distributions") }}
),
s3_origins_with_buckets AS (
SELECT DISTINCT
    s.arn,
    s.origin_access_control_id
FROM
    s3_origins s
INNER JOIN {{ full_table_name("aws_s3_buckets") }} b ON SPLIT(s3_domain_name, '.')[OFFSET(0)] = b.name
 )
  
SELECT DISTINCT
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'CloudFront distributions should use origin access control' as title,
    d.account_id,
    d.arn as resouce_id,
    CASE
        WHEN o.arn is not null 
            and (o.origin_access_control_id is null 
            or o.origin_access_control_id = '') THEN 'fail'
        ELSE 'pass'
    END as status
    
FROM {{ full_table_name("aws_cloudfront_distributions") }} as d 
LEFT JOIN s3_origins_with_buckets as o ON d.arn = o.arn
WHERE {{ partition_filter("d") }}
{% endmacro %}
