{% macro ec2_instances_should_be_scanned_by_inspector(framework, check_id) %}
  {{ return(adapter.dispatch('ec2_instances_should_be_scanned_by_inspector')(framework, check_id)) }}
{% endmacro %}

{% macro default__ec2_instances_should_be_scanned_by_inspector(framework, check_id) %}{% endmacro %}

{% macro bigquery__ec2_instances_should_be_scanned_by_inspector(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'EC2 instances should be scanned by Inspector' as title,
    ec2.arn as identifier,
    null as metadata,
    case when icr.scan_status is not null
        and JSON_VALUE(icr.scan_status, '$.StatusCode') = 'ACTIVE'
    then 'pass'
    else 'fail'
end as status,
    ec2.tags
from {{ full_table_name("aws_ec2_instances") }} ec2
left join {{ full_table_name("aws_inspector2_covered_resources") }} as icr
    on ec2.instance_id = icr.resource_id
    {{ partition_join("icr", "ec2") }}
where {{ partition_filter("ec2") }}
    {% endmacro %}