{% macro unencrypted_efs_filesystems(framework, check_id) %}
  {{ return(adapter.dispatch('unencrypted_efs_filesystems')(framework, check_id)) }}
{% endmacro %}

{% macro default__unencrypted_efs_filesystems(framework, check_id) %}{% endmacro %}

{% macro bigquery__unencrypted_efs_filesystems(framework, check_id) %}
select
  '{{framework}}' As framework,
  '{{check_id}}' As check_id,
  'Amazon EFS should be configured to encrypt file data at rest using AWS KMS' as title,
  account_id,
  arn as resource_id,
  case when
    encrypted is distinct from TRUE
    or kms_key_id is null
    then 'fail'
    else 'pass'
  end as status
from {{ full_table_name("aws_efs_filesystems") }}
where {{ partition_filter("aws_efs_filesystems") }}
{% endmacro %}
