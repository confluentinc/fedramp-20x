{% macro networks_acls_ingress_rules(framework, check_id) %}
  {{ return(adapter.dispatch('networks_acls_ingress_rules')()) }}
{% endmacro %}

{% macro default__networks_acls_ingress_rules() %}{% endmacro %}

{% macro bigquery__networks_acls_ingress_rules() %}
WITH rules AS (SELECT aena.arn,
                      aena.account_id,
                      CAST(JSON_VALUE(port_range_from) AS INT64) as port_range_from,
                      CAST(JSON_VALUE(port_range_to) AS INT64) as port_range_to,
                      JSON_VALUE(protocol) as protocol,
                      JSON_VALUE(cidr_block) as cidr_block,
                      JSON_VALUE(ipv6_cidr_block) as ipv6_cidr_block,
                      JSON_VALUE(egress) as egress,
                      JSON_VALUE(rule_action) as rule_action
               FROM {{ full_table_name("aws_ec2_network_acls") }} aena,
               UNNEST(JSON_QUERY_ARRAY(entries.PortRange.From)) AS port_range_from,
               UNNEST(JSON_QUERY_ARRAY(entries.PortRange.To)) AS port_range_to,
               UNNEST(JSON_QUERY_ARRAY(entries.Protocol)) AS protocol,
               UNNEST(JSON_QUERY_ARRAY(entries.CidrBlock)) AS cidr_block,
               UNNEST(JSON_QUERY_ARRAY(entries.Ipv6CidrBlock)) AS ipv6_cidr_block,
               UNNEST(JSON_QUERY_ARRAY(entries.Egress)) AS egress,
               UNNEST(JSON_QUERY_ARRAY(entries.RuleAction)) AS rule_action
               WHERE {{ partition_filter("aena") }}
               )
SELECT arn, account_id, port_range_from, port_range_to, protocol, cidr_block, ipv6_cidr_block
FROM rules
WHERE egress IS DISTINCT FROM 'true'
  AND rule_action = 'allow'
{% endmacro %}
