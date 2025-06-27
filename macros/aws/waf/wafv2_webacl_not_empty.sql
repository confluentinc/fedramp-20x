{% macro wafv2_webacl_not_empty(framework, check_id) %}
  {{ return(adapter.dispatch('wafv2_webacl_not_empty')(framework, check_id)) }}
{% endmacro %}

{% macro default__wafv2_webacl_not_empty(framework, check_id) %}{% endmacro %}

{% macro bigquery__wafv2_webacl_not_empty(framework, check_id) %}
select
	'{{framework}}' As framework,
    '{{check_id}}' As check_id,
	'A WAFv2 web ACL should have at least one rule or rule group' as title,
	account_id,
	arn,
	CASE
	WHEN ARRAY_LENGTH(JSON_QUERY_ARRAY(rules)) > 0 or ARRAY_LENGTH(JSON_QUERY_ARRAY(POST_PROCESS_FIREWALL_MANAGER_RULE_GROUPS)) > 0 or ARRAY_LENGTH(JSON_QUERY_ARRAY(PRE_PROCESS_FIREWALL_MANAGER_RULE_GROUPS)) > 0 THEN 'pass'
    ELSE 'fail'
	END AS rule_status
FROM
  {{ full_table_name("aws_wafv2_web_acls") }}
where {{ partition_filter("aws_wafv2_web_acls") }}
{% endmacro %}
