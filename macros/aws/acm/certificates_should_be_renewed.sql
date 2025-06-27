{% macro certificates_should_be_renewed(framework, check_id) %}
  {{ return(adapter.dispatch('certificates_should_be_renewed')(framework, check_id)) }}
{% endmacro %}

{% macro default__certificates_should_be_renewed(framework, check_id) %}{% endmacro %}

{% macro bigquery__certificates_should_be_renewed(framework, check_id) %}
select
  '{{framework}}' As framework,
  '{{check_id}}' As check_id,
  'certificate has less than 30 days to be renewed' as title,
  account_id,
  arn AS resource_id,
  case when
    not_after < CAST( {{ dbt.dateadd('day', 30, 'current_date') }} AS TIMESTAMP ) 
    then 'fail'
    else 'pass'
  end as status
FROM {{ full_table_name("aws_acm_certificates") }}
WHERE {{ partition_filter() }}
{% endmacro %}
