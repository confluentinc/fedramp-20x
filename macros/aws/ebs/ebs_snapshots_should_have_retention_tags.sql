{% macro ebs_snapshots_should_have_retention_tags(framework, check_id) %}
  {{ return(adapter.dispatch('ebs_snapshots_should_have_retention_tags')(framework, check_id)) }}
{% endmacro %}

{% macro default__ebs_snapshots_should_have_retention_tags(framework, check_id) %}{% endmacro %}

{% macro bigquery__ebs_snapshots_should_have_retention_tags(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'EBS snapshots should have retention policies or lifecycle tags' as title,
    arn as identifier,
    JSON_OBJECT() as metadata,
    case when
        (
            JSON_VALUE(tags, '$.dlm:managed') IS NOT NULL
        ) or (
            JSON_VALUE(tags, '$.CreatedBy') = 'EC2 Image Builder'
        )
        then 'pass'
        else 'fail'
    end as status,
    tags
from {{ full_table_name("aws_ec2_ebs_snapshots") }}
where {{ partition_filter() }}
    and state = 'completed'
{% endmacro %}
