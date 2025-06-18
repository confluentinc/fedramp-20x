{% macro documents_should_not_be_public(framework, check_id) %}
  {{ return(adapter.dispatch('documents_should_not_be_public')(framework, check_id)) }}
{% endmacro %}

{% macro default__documents_should_not_be_public(framework, check_id) %}{% endmacro %}

{% macro bigquery__documents_should_not_be_public(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'SSM documents should not be public' as title,
    account_id,
    arn as resource_id,
    case when 'all' IN UNNEST(JSON_EXTRACT_STRING_ARRAY(p.AccountIds)) then 'fail' else 'pass' end as status
from {{ full_table_name("aws_ssm_documents") }},
  UNNEST(JSON_QUERY_ARRAY(aws_ssm_documents.permissions)) AS p
where owner in (select account_id from {{ full_table_name("aws_iam_accounts") }})
and {{ partition_filter("aws_ssm_documents") }}
{% endmacro %}
