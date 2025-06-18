{% macro lambda_functions_should_use_supported_runtimes(framework, check_id) %}
  {{ return(adapter.dispatch('lambda_functions_should_use_supported_runtimes')(framework, check_id)) }}
{% endmacro %}

{% macro default__lambda_functions_should_use_supported_runtimes(framework, check_id) %}{% endmacro %}

{% macro bigquery__lambda_functions_should_use_supported_runtimes(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'Lambda functions should use supported runtimes' AS title,
    f.account_id,
    f.arn AS resource_id,
    CASE WHEN r.name IS NULL THEN 'fail'
    ELSE 'pass' END AS status
FROM {{ full_table_name("aws_lambda_functions") }} f
LEFT JOIN {{ full_table_name("aws_lambda_runtimes") }} r ON r.name = CAST( JSON_VALUE(f.configuration.Runtime) AS STRING)
and {{ partition_join("f", "r") }}
WHERE  CAST( JSON_VALUE(f.configuration.PackageType) AS STRING) != 'Image'
and {{ partition_filter("f") }}
{% endmacro %}
