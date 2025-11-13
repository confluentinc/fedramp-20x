{% macro ec2_instances_should_use_current_generation_types(framework, check_id) %}
  {{ return(adapter.dispatch('ec2_instances_should_use_current_generation_types')(framework, check_id)) }}
{% endmacro %}

{% macro default__ec2_instances_should_use_current_generation_types(framework, check_id) %}{% endmacro %}

{% macro bigquery__ec2_instances_should_use_current_generation_types(framework, check_id) %}
-- Check instances use current generation types (for security patches)
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'EC2 instances should use current generation instance types for latest patches' as title,
    account_id,
    instance_id as resource_id,
    case when
        -- Old generation types (m1, m2, m3, t1, c1, c3, r3, etc.)
        REGEXP_CONTAINS(instance_type, r'^(m1\.|m2\.|m3\.|t1\.|c1\.|c3\.|r3\.|i2\.|g2\.|d2\.)')
        then 'fail'
        else 'pass'
    end as status
from {{ full_table_name("aws_ec2_instances") }}
where {{ partition_filter() }}
    and JSON_VALUE(state.Name) != 'terminated'
{% endmacro %}
