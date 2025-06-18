{% macro instances_should_have_association_compliance_status_of_compliant(framework, check_id) %}
  {{ return(adapter.dispatch('instances_should_have_association_compliance_status_of_compliant')(framework, check_id)) }}
{% endmacro %}

{% macro default__instances_should_have_association_compliance_status_of_compliant(framework, check_id) %}{% endmacro %}

{% macro bigquery__instances_should_have_association_compliance_status_of_compliant(framework, check_id) %}
with association_compliance_status_groups as(
    select
        instance_arn,
        status
    from
        {{ full_table_name("aws_ssm_instance_compliance_items") }}
    where
        compliance_type = 'Association' and {{ partition_filter() }}
)
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'Amazon EC2 instances managed by Systems Manager should have an association compliance status of COMPLIANT' as title,
    aws_ssm_instances.account_id,
    aws_ssm_instances.arn,
    case when
		association_compliance_status_groups.status is distinct from 'COMPLIANT'
     then 'fail' else 'pass' end as status
 from
     {{ full_table_name("aws_ssm_instances") }}
	 inner join association_compliance_status_groups
         on aws_ssm_instances.arn = association_compliance_status_groups.instance_arn
where {{ partition_filter("aws_ssm_instances") }}
{% endmacro %}
