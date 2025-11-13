{% macro ebs_snapshots_should_have_retention_tags(framework, check_id) %}
  {{ return(adapter.dispatch('ebs_snapshots_should_have_retention_tags')(framework, check_id)) }}
{% endmacro %}

{% macro default__ebs_snapshots_should_have_retention_tags(framework, check_id) %}{% endmacro %}

{% macro bigquery__ebs_snapshots_should_have_retention_tags(framework, check_id) %}
select
    '{{framework}}' as framework,
    '{{check_id}}' as check_id,
    'EBS snapshots should have retention policies or lifecycle tags' as title,
    account_id,
    snapshot_id as resource_id,
    case when
        JSON_EXTRACT_SCALAR(tags, '$.Retention') is null
        and JSON_EXTRACT_SCALAR(tags, '$.Lifecycle') is null
        and JSON_EXTRACT_SCALAR(tags, '$.DeleteAfter') is null
        and TIMESTAMP_DIFF(CURRENT_TIMESTAMP(), start_time, DAY) > 180
        then 'fail'
        else 'pass'
    end as status
from {{ full_table_name("aws_ec2_ebs_snapshots") }}
where {{ partition_filter() }}
    and state = 'completed'
{% endmacro %}
