{% macro ebs_volumes_should_be_encrypted_at_rest(framework, check_id) %}
  {{ return(adapter.dispatch('ebs_volumes_should_be_encrypted_at_rest')(framework, check_id)) }}
{% endmacro %}

{% macro default__ebs_volumes_should_be_encrypted_at_rest(framework, check_id) %}{% endmacro %}

{% macro bigquery__ebs_volumes_should_be_encrypted_at_rest(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'EBS Volumes should be encrypted at rest' as title,
    arn as identifier,
    null as metadata,
    case when encrypted = true
         then 'pass'
         else 'fail'
    end as status
from {{ full_table_name("aws_ec2_ebs_volumes") }}
{% endmacro %}