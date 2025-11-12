{% macro unused_security_groups_should_be_removed(framework, check_id) %}
  {{ return(adapter.dispatch('unused_security_groups_should_be_removed')(framework, check_id)) }}
{% endmacro %}

{% macro default__unused_security_groups_should_be_removed(framework, check_id) %}{% endmacro %}

{% macro bigquery__unused_security_groups_should_be_removed(framework, check_id) %}
with attached_sgs as (
    select distinct JSON_VALUE(sg.GroupId) as group_id
    from {{ full_table_name("aws_ec2_instances") }},
    unnest(JSON_EXTRACT_ARRAY(security_groups)) as sg
    where {{ partition_filter() }}
)
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Security groups should be associated with resources' as title,
    sg.account_id,
    sg.group_id as resource_id,
    case when
        sg.group_name != 'default'
        and attached_sgs.group_id is null
        then 'fail'
        else 'pass'
    end as status
from {{ full_table_name("aws_ec2_security_groups") }} sg
left join attached_sgs on sg.group_id = attached_sgs.group_id
where {{ partition_filter("sg") }}
{% endmacro %}
