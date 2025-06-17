{% macro distribution_should_use_ssl_tls_certificates(framework, check_id) %}
  {{ return(adapter.dispatch('distribution_should_use_ssl_tls_certificates')(framework, check_id)) }}
{% endmacro %}

{% macro default__distribution_should_use_ssl_tls_certificates(framework, check_id) %}{% endmacro %}

{% macro bigquery__distribution_should_use_ssl_tls_certificates(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'CloudFront distributions should use custom SSL/TLS certificates' as title,
    account_id,
    arn as resource_id,
    CASE 
        WHEN (distribution_config.ViewerCertificate.ACMCertificateArn is null
            AND
            distribution_config.ViewerCertificate.IAMCertificateId is null
            ) 
            OR CAST( JSON_VALUE(distribution_config.ViewerCertificate.CloudFrontDefaultCertificate) AS BOOL) = true
        THEN 'fail'
        ELSE 'pass'
    END as status
from {{ full_table_name("aws_cloudfront_distributions") }}
where {{ partition_filter() }}
{% endmacro %}
