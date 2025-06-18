{% macro lambda_function_prohibit_public_access(framework, check_id) %}
  {{ return(adapter.dispatch('lambda_function_prohibit_public_access')(framework, check_id)) }}
{% endmacro %}

{% macro default__lambda_function_prohibit_public_access(framework, check_id) %}{% endmacro %}

{% macro bigquery__lambda_function_prohibit_public_access(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Lambda functions should prohibit public access' as title,
    account_id,
    arn as resource_id,
    'fail' as status -- TODO FIXME
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
