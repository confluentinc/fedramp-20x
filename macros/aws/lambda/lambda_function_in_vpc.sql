{% macro lambda_function_in_vpc(framework, check_id) %}
  {{ return(adapter.dispatch('lambda_function_in_vpc')(framework, check_id)) }}
{% endmacro %}

{% macro default__lambda_function_in_vpc(framework, check_id) %}{% endmacro %}

{% macro bigquery__lambda_function_in_vpc(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Lambda functions should be in a VPC' AS title,
    account_id,
    arn as resource_id,
    case when configuration.VpcConfig.VpcId is null or JSON_VALUE(configuration.VpcConfig.VpcId) = '' then 'fail' else 'pass' end as status
from {{ full_table_name("aws_lambda_functions") }}
where {{ partition_filter() }}
{% endmacro %}
