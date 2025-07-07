{% macro gcp_cis_compliance_summary(framework, check_id) %}
  {{ return(adapter.dispatch('gcp_cis_compliance_summary')(framework, check_id)) }}
{% endmacro %}

{% macro default__gcp_cis_compliance_summary(framework, check_id) %}{% endmacro %}

{% macro bigquery__gcp_cis_compliance_summary(framework, check_id) %}
with compliance as (
    select
        count(*) as total,
        SUM(case when status = 'pass' then 1 else 0 end) as passed
    from {{ ref("gcp_compliance__cis_v2_0_0")}}
)  select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'GCP CIS v2 Compliance (Scored)' as title,
    'GCP CIS v2' as identifier,
    JSON_OBJECT('total', total, 'passed', passed, 'score', passed / total) as metadata,
    case when (passed / total) >= 0.8 then 'pass'
        else 'fail'
    end as status,
    JSON_OBJECT() as tags
from compliance
    {% endmacro %}
