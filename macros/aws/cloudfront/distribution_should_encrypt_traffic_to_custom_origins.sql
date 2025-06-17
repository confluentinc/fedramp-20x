{% macro distribution_should_encrypt_traffic_to_custom_origins(framework, check_id) %}
  {{ return(adapter.dispatch('distribution_should_encrypt_traffic_to_custom_origins')(framework, check_id)) }}
{% endmacro %}

{% macro default__distribution_should_encrypt_traffic_to_custom_origins(framework, check_id) %}{% endmacro %}

{% macro bigquery__distribution_should_encrypt_traffic_to_custom_origins(framework, check_id) %}
with origins as (
    select distinct
        arn,
        JSON_VALUE(f.CustomOriginConfig.OriginProtocolPolicy) as policy
    from
        {{ full_table_name("aws_cloudfront_distributions") }} d,
 UNNEST(JSON_QUERY_ARRAY(distribution_config.Origins.Items)) AS f
    WHERE
        (JSON_VALUE(f.CustomOriginConfig.OriginProtocolPolicy) = 'http-only'
        or JSON_VALUE(f.CustomOriginConfig.OriginProtocolPolicy) = 'match-viewer')
    and {{ partition_filter("d") }}


),
cache_behaviors as (
    select distinct 
        arn
    from
        {{ full_table_name("aws_cloudfront_distributions") }} d,
 UNNEST(JSON_QUERY_ARRAY(distribution_config.CacheBehaviors.Items)) AS f
    where
        JSON_VALUE(f.ViewerProtocolPolicy) = 'allow-all'
    and {{ partition_filter("d") }}
)
select distinct
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'CloudFront distributions should encrypt traffic to custom origins' as title,
    d.account_id,
    d.arn as resource_id,
    CASE
        WHEN o.policy = 'http-only' THEN 'fail'
        WHEN o.policy = 'match-viewer' and (cb.arn is not null 
                                            or
                                            JSON_VALUE(distribution_config.DefaultCacheBehavior.ViewerProtocolPolicy) = 'allow-all') 
                                            THEN 'fail'
        ELSE 'pass'
    END as status
    

from
    {{ full_table_name("aws_cloudfront_distributions") }} d
    LEFT JOIN origins as o on d.arn = o.arn
    LEFT JOIN cache_behaviors as cb on d.arn = cb.arn
where {{ partition_filter("d") }}
{% endmacro %}
