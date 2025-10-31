{% macro okta_behavior_rules_suspicious_activity_requires_mfa(framework, check_id) %}
  {{ return(adapter.dispatch('okta_behavior_rules_suspicious_activity_requires_mfa')(framework, check_id)) }}
{% endmacro %}

{% macro default__okta_behavior_rules_suspicious_activity_requires_mfa(framework, check_id) %}{% endmacro %}

{% macro bigquery__okta_behavior_rules_suspicious_activity_requires_mfa(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    CONCAT('Okta behavior rules will lock compromised accounts due to: ', name, ' (', type, ')') as title,
    id as identifier,
    settings as metadata,
    'pass' as status, -- This isn't a pass / fail control, we simply identify the compromise controls
    JSON_OBJECT() as tags
from {{ full_table_name("okta_behavior_rules") }}
where {{ partition_filter() }}
and UPPER(status) = 'ACTIVE'
{% endmacro %}