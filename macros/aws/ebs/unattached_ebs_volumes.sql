{% macro unattached_ebs_volumes(framework, check_id) %}
  {{ return(adapter.dispatch('unattached_ebs_volumes')(framework, check_id)) }}
{% endmacro %}

{% macro default__unattached_ebs_volumes(framework, check_id) %}{% endmacro %}

{% macro bigquery__unattached_ebs_volumes(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'EBS volumes should be attached to EC2 instances' as title,
    account_id,
    volume_id as resource_id,
    case when
        state = 'available'
        and DATETIME_DIFF(CURRENT_DATETIME(), DATETIME(create_time), DAY) > 7
        then 'fail'
        else 'pass'
    end as status
from {{ full_table_name("aws_ec2_ebs_volumes") }}
where {{ partition_filter() }}
{% endmacro %}
