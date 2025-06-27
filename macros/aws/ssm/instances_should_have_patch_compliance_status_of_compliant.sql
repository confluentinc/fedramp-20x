{% macro instances_should_have_patch_compliance_status_of_compliant(framework, check_id) %}
  {{ return(adapter.dispatch('instances_should_have_patch_compliance_status_of_compliant')(framework, check_id)) }}
{% endmacro %}

{% macro default__instances_should_have_patch_compliance_status_of_compliant(framework, check_id) %}{% endmacro %}

{% macro bigquery__instances_should_have_patch_compliance_status_of_compliant(framework, check_id) %}
with patch_compliance_status_groups as(
    select DISTINCT
        instance_arn,
        status
    from
        {{ full_table_name("aws_ssm_instance_compliance_items") }}
    where
        compliance_type = 'Patch'
    and {{ partition_filter() }}
)
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Amazon EC2 instances managed by Systems Manager should have a patch compliance status of COMPLIANT after a patch installation' as title,
    aws_ssm_instances.account_id,
    aws_ssm_instances.arn,
    case when
        patch_compliance_status_groups.status is distinct from 'COMPLIANT'
     then 'fail' else 'pass' end as status
 from
     {{ full_table_name("aws_ssm_instances") }}
INNER join patch_compliance_status_groups 
    on aws_ssm_instances.arn = patch_compliance_status_groups.instance_arn
where {{ partition_filter("aws_ssm_instances") }}
{% endmacro %}
