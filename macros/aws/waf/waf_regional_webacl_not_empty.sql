{% macro waf_regional_webacl_not_empty(framework, check_id) %}
  {{ return(adapter.dispatch('waf_regional_webacl_not_empty')(framework, check_id)) }}
{% endmacro %}

{% macro default__waf_regional_webacl_not_empty(framework, check_id) %}{% endmacro %}

{% macro bigquery__waf_regional_webacl_not_empty(framework, check_id) %}
select
	'{{framework}}' As framework,
    '{{check_id}}' As check_id,
	'A WAF Regional web ACL should have at least one rule or rule group' as title,
	account_id,
	arn as resource_id,
	case  
		WHEN ARRAY_LENGTH(JSON_QUERY_ARRAY(rules)) = 0 THEN 'fail'
		else 'pass'
        end as status
from
  {{ full_table_name("aws_wafregional_web_acls") }}
where {{ partition_filter("aws_wafregional_web_acls") }}
{% endmacro %}
