{% macro waf_regional_rule_not_empty(framework, check_id) %}
  {{ return(adapter.dispatch('waf_regional_rule_not_empty')(framework, check_id)) }}
{% endmacro %}

{% macro default__waf_regional_rule_not_empty(framework, check_id) %}{% endmacro %}

{% macro bigquery__waf_regional_rule_not_empty(framework, check_id) %}
select
	'{{framework}}' As framework,
    '{{check_id}}' As check_id,
	'A WAF Regional rule should have at least one condition' as title,
	account_id,
	arn as resource_id,
	case 
		WHEN 
        predicates is null 
        or ARRAY_LENGTH(JSON_QUERY_ARRAY(predicates)) = 0 then 'fail'
		else 'pass'
        end as status
from
    {{ full_table_name("aws_wafregional_rules") }}
where {{ partition_filter("aws_wafregional_rules") }}
{% endmacro %}
