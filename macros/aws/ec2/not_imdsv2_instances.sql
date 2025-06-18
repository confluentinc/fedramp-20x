{% macro not_imdsv2_instances(framework, check_id) %}
  {{ return(adapter.dispatch('not_imdsv2_instances')(framework, check_id)) }}
{% endmacro %}

{% macro default__not_imdsv2_instances(framework, check_id) %}{% endmacro %}

{% macro bigquery__not_imdsv2_instances(framework, check_id) %}
select
  '{{framework}}' As framework,
  '{{check_id}}' As check_id,
  'EC2 instances should use IMDSv2' as title,
  account_id,
  instance_id as resource_id,
  case when
    JSON_VALUE(metadata_options.HttpTokens) is distinct from 'required'
    then 'fail'
    else 'pass'
  end as status
from {{ full_table_name("aws_ec2_instances") }}
    where {{ partition_filter() }}
{% endmacro %}
