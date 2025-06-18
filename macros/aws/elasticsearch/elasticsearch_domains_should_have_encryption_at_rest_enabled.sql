{% macro elasticsearch_domains_should_have_encryption_at_rest_enabled(framework, check_id) %}
  {{ return(adapter.dispatch('elasticsearch_domains_should_have_encryption_at_rest_enabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__elasticsearch_domains_should_have_encryption_at_rest_enabled(framework, check_id) %}{% endmacro %}
                    
{% macro bigquery__elasticsearch_domains_should_have_encryption_at_rest_enabled(framework, check_id) %}
select
  '{{framework}}' as framework,
  '{{check_id}}' as check_id,
  'Elasticsearch domains should have encryption at rest enabled' as title,
  account_id,
  arn as resource_id,
  case when
        CAST( JSON_VALUE(encryption_at_rest_options.Enabled) AS BOOL) is not true
    then 'fail'
    else 'pass'
  end as status
from {{ full_table_name("aws_elasticsearch_domains") }}
where {{ partition_filter() }}
{% endmacro %}  
