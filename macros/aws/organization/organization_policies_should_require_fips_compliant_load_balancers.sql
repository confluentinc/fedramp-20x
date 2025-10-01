{% macro organization_policies_should_require_fips_compliant_load_balancers(framework, check_id) %}
  {{ return(adapter.dispatch('organization_policies_should_require_fips_compliant_load_balancers')(framework, check_id)) }}
{% endmacro %}

{% macro default__organization_policies_should_require_fips_compliant_load_balancers(framework, check_id) %}{% endmacro %}

{% macro bigquery__organization_policies_should_require_fips_compliant_load_balancers(framework, check_id) %}

{{ organization_policy_check(
    framework,
    check_id,
    'Organization policies should require FIPS compliant load balancers',
    ["elasticloadbalancing:ModifyListener", "elasticloadbalancing:CreateListener"],
    "ForAnyValue:StringNotEquals",
    "elasticloadbalancing:SecurityPolicy",
    "ELBSecurityPolicy-TLS13-1-2-FIPS-2023-04"
)}}

{% endmacro %}