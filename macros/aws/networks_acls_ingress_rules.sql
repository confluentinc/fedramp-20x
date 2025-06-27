{% macro networks_acls_ingress_rules(framework, check_id) %}
  {{ return(adapter.dispatch('networks_acls_ingress_rules')()) }}
{% endmacro %}

{% macro default__networks_acls_ingress_rules() %}{% endmacro %}

{% macro bigquery__networks_acls_ingress_rules() %}
WITH rules AS (SELECT aena.arn,
                      aena.account_id,
                      JSON_VALUE(entry, "$.PortRange.From") as port_range_from,
                      JSON_VALUE(entry, "$.PortRange.To") as port_range_to,
                      JSON_VALUE(entry, "$.Protocol") as protocol,
                      JSON_VALUE(entry, "$.CidrBlock") as cidr_block,
                      JSON_VALUE(entry, "$.Ipv6CidrBlock") as ipv6_cidr_block,
                      JSON_VALUE(entry, "$.Egress") as egress,
                      JSON_VALUE(entry, "$.RuleAction") as rule_action
               FROM {{ full_table_name("aws_ec2_network_acls") }} aena,
               UNNEST(JSON_QUERY_ARRAY(entries)) AS entry
               WHERE {{ partition_filter("aena") }}
               )
SELECT arn, account_id, port_range_from, port_range_to, protocol, cidr_block, ipv6_cidr_block
FROM rules
WHERE egress IS DISTINCT FROM 'true'
  AND rule_action = 'allow'
{% endmacro %}
