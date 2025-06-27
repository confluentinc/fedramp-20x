{% macro unencrypted_ebs_volumes(framework, check_id) %}
  {{ return(adapter.dispatch('unencrypted_ebs_volumes')(framework, check_id)) }}
{% endmacro %}

{% macro default__unencrypted_ebs_volumes(framework, check_id) %}{% endmacro %}

{% macro bigquery__unencrypted_ebs_volumes(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'Attached EBS volumes should be encrypted at rest' as title,
    account_id,
    arn as resource_id,
    case when
        encrypted = FALSE
        then 'fail'
        else 'pass'
    end as status
from {{ full_table_name("aws_ec2_ebs_volumes") }}
where {{ partition_filter("aws_ec2_ebs_volumes") }}
{% endmacro %}
