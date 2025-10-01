{% macro organization_policies_should_block_unencrypted_rds_instances(framework, check_id) %}
  {{ return(adapter.dispatch('organization_policies_should_block_unencrypted_rds_instances')(framework, check_id)) }}
{% endmacro %}

{% macro default__organization_policies_should_block_unencrypted_rds_instances(framework, check_id) %}{% endmacro %}

{% macro bigquery__organization_policies_should_block_unencrypted_rds_instances(framework, check_id) %}

{{ organization_policy_check(
    framework,
    check_id,
    'Organization policies should block creation of unencrypted RDS resources',
    ["rds:RestoreDB*", "rds:CreateDBInstance", "rds:CreateDBCluster"],
    "Bool",
    "rds:StorageEncrypted",
    "false"
)}}

{% endmacro %}