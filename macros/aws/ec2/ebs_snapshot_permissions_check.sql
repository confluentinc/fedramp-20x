{% macro ebs_snapshot_permissions_check(framework, check_id) %}
  {{ return(adapter.dispatch('ebs_snapshot_permissions_check')(framework, check_id)) }}
{% endmacro %}

{% macro default__ebs_snapshot_permissions_check(framework, check_id) %}{% endmacro %}
{% macro bigquery__ebs_snapshot_permissions_check(framework, check_id) %}
WITH snapshot_access_groups AS (
    SELECT account_id,
           region,
           snapshot_id,
           groupa,
           user_id
    FROM {{ full_table_name("aws_ec2_ebs_snapshot_attributes") }},
    UNNEST(JSON_QUERY_ARRAY(create_volume_permissions.Group)) AS groupa,
    UNNEST(JSON_QUERY_ARRAY(create_volume_permissions.UserId)) AS user_id
    WHERE {{ partition_filter("aws_ec2_ebs_snapshot_attributes") }}
)
SELECT DISTINCT
  '{{framework}}' as framework,
  '{{check_id}}' as check_id,
  'Amazon EBS snapshots should not be public, determined by the ability to be restorable by anyone' as title,
  account_id,
  snapshot_id as resource_id,
  case when
    JSON_VALUE(groupa) = 'all'
    then 'fail'
    else 'pass'
  end as status
FROM snapshot_access_groups
{% endmacro %}                    
