{% macro lambda_function_public_access_prohibited(framework, check_id) %}
  {{ return(adapter.dispatch('lambda_function_public_access_prohibited')(framework, check_id)) }}
{% endmacro %}

{% macro default__lambda_function_public_access_prohibited(framework, check_id) %}{% endmacro %}

{% macro bigquery__lambda_function_public_access_prohibited(framework, check_id) %}
with wildcards as
  (
    SELECT
    arn
    FROM
    {{ full_table_name("aws_lambda_functions") }}
    LEFT JOIN UNNEST(JSON_QUERY_ARRAY(policy_document.Statement)) AS statement
    where
      JSON_VALUE(statement.Effect) = 'Allow'
      and
        (JSON_VALUE(statement.Principal) = '*'
        or
        (JSON_VALUE(statement.Principal.AWS) = '["*"]'))
      and
        json_query(statement, '$.Condition') is null
      and {{ partition_filter("aws_lambda_functions") }}
      )
  select DISTINCT
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'Lambda function policies should prohibit public access' AS title,
    alf.account_id,
    alf.arn AS resource_id,
    case when wildcards.arn is null then 'pass'
	  else 'fail' end as status
  from {{ full_table_name("aws_lambda_functions") }} alf
  left join wildcards on alf.arn = wildcards.arn
  where {{ partition_filter("alf") }}
{% endmacro %}
