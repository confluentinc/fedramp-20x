{% macro lambda_functions_with_public_access() %}
  {{ return(adapter.dispatch('lambda_functions_with_public_access')()) }}
{% endmacro %}

{% macro default__lambda_functions_with_public_access() %}{% endmacro %}

{% macro bigquery__lambda_functions_with_public_access() %}
select
    'Lambda functions with public access' as title,
    aws_lambda_functions.account_id,
    aws_lambda_functions.arn as resource_id,
    'aws_lambda_functions' as resource_type,
    'public_invocation' as reachability_type,
    NULL as from_port,
    NULL as to_port,
    NULL as protocol,
    '' as endpoint,
    NULL as endpoint_type
from {{ full_table_name("aws_lambda_functions") }},
     UNNEST(JSON_QUERY_ARRAY(policy_document.Statement)) AS statement
where   JSON_VALUE(statement.Effect) = 'Allow'
  and (
    JSON_VALUE(statement.Principal) = '*'
        or JSON_VALUE(statement.Principal.AWS) = '*'

        or ( '*' IN UNNEST(JSON_EXTRACT_STRING_ARRAY(statement.Principal.AWS)) )
    )
  and {{ partition_filter("aws_lambda_functions") }}
    {% endmacro %}
