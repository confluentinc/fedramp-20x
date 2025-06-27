{% macro viewer_policy_https(framework, check_id) %}
  {{ return(adapter.dispatch('viewer_policy_https')(framework, check_id)) }}
{% endmacro %}

{% macro default__viewer_policy_https(framework, check_id) %}{% endmacro %}

{% macro bigquery__viewer_policy_https(framework, check_id) %}
WITH cachebeviors AS (
    -- Handle all non-defaults as well as when there is only a default route
    SELECT DISTINCT arn, account_id 
    FROM (
        SELECT arn, account_id, d AS CacheBehavior 
        FROM {{ full_table_name("aws_cloudfront_distributions") }},
        UNNEST(JSON_QUERY_ARRAY(distribution_config.CacheBehaviors.Items)) AS d
        WHERE distribution_config.CacheBehaviors.Items IS NOT NULL
        AND {{ partition_filter("aws_cloudfront_distributions") }}
        UNION ALL
        -- Handle default Cachebehaviors
        SELECT arn, account_id, distribution_config.DefaultCacheBehavior AS CacheBehavior 
        FROM {{ full_table_name("aws_cloudfront_distributions") }}
        WHERE {{ partition_filter("aws_cloudfront_distributions") }}
    ) AS cachebeviors 
    WHERE CAST(JSON_VALUE(CacheBehavior.ViewerProtocolPolicy) AS STRING) = 'allow-all'
)
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'CloudFront distributions should require encryption in transit' as title,
    account_id,
    arn as resource_id,
    'fail' as status
from cachebeviors
{% endmacro %}
