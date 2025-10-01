{% macro organization_policies_should_block_unencrypted_ec2_instances(framework, check_id) %}
  {{ return(adapter.dispatch('organization_policies_should_block_unencrypted_ec2_instances')(framework, check_id)) }}
{% endmacro %}

{% macro default__organization_policies_should_block_unencrypted_ec2_instances(framework, check_id) %}{% endmacro %}

{% macro bigquery__organization_policies_should_block_unencrypted_ec2_instances(framework, check_id) %}

{{ organization_policy_check(
    framework,
    check_id,
    'Organization policies should block creation of unencrypted EC2 instances',
    ["ec2:RunInstances", "ec2:CreateVolume"],
    "Bool",
    "ec2:Encrypted",
    "false"
)}}

{% endmacro %}