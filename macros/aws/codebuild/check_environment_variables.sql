{% macro check_environment_variables(framework, check_id) %}
  {{ return(adapter.dispatch('check_environment_variables')(framework, check_id)) }}
{% endmacro %}

{% macro default__check_environment_variables(framework, check_id) %}{% endmacro %}
{% macro bigquery__check_environment_variables(framework, check_id) %}
select distinct
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'CodeBuild project environment variables should not contain clear text credentials' as title,
    account_id,
    arn as resource_id,
    case when
            JSON_VALUE(e.Type) = 'PLAINTEXT'
            and (
                UPPER(JSON_VALUE(e.Name)) like '%ACCESS_KEY%' or
                UPPER(JSON_VALUE(e.Name)) like '%SECRET%' or
                UPPER(JSON_VALUE(e.Name)) like '%PASSWORD%'
            )
            then 'fail'
        else 'pass'
    end as status
from {{ full_table_name("aws_codebuild_projects") }},
UNNEST(JSON_QUERY_ARRAY(environment.EnvironmentVariables)) AS e
WHERE {{ partition_filter() }}
{% endmacro %}
