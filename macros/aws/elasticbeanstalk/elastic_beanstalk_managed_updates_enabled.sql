{% macro elastic_beanstalk_managed_updates_enabled(framework, check_id) %}
  {{ return(adapter.dispatch('elastic_beanstalk_managed_updates_enabled')(framework, check_id)) }}
{% endmacro %}

{% macro default__elastic_beanstalk_managed_updates_enabled(framework, check_id) %}{% endmacro %}

{% macro bigquery__elastic_beanstalk_managed_updates_enabled(framework, check_id) %}
select
  '{{framework}}' As framework,
  '{{check_id}}' As check_id,
  'Elastic Beanstalk managed platform updates should be enabled' as title,
  account_id,
  application_arn as resource_id,
  case when
    JSON_VALUE(s.OptionName) = 'ManagedActionsEnabled' AND CAST( JSON_VALUE(s.Value) AS BOOL) is distinct from true
    then 'fail'
    else 'pass'
  end as status
from {{ full_table_name("aws_elasticbeanstalk_configuration_settings") }},
UNNEST(JSON_QUERY_ARRAY(option_settings)) AS s
where {{ partition_filter("aws_elasticbeanstalk_configuration_settings") }}
{% endmacro %}
