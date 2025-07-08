{% macro aws_cis_compliance_summary(framework, check_id) %}
  {{ return(adapter.dispatch('aws_cis_compliance_summary')(framework, check_id)) }}
{% endmacro %}

{% macro default__aws_cis_compliance_summary(framework, check_id) %}{% endmacro %}

{% macro bigquery__aws_cis_compliance_summary(framework, check_id) %}
with compliance as (
    select
        count(*) as total,
        SUM(case when status = 'pass' then 1 else 0 end) as passed
     from {{ ref("aws_compliance__cis_v3_0_0")}}
     where check_id NOT IN ({{ to_sql_list(var('ksi_cna_07_excluded_controls'))}})
     and account_id IN ({{ to_sql_list(var('ksi_cna_07_account_ids'))}})
)  select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'AWS CIS v3 Compliance (Scored)' as title,
    'AWS CIS v3' as identifier,
    JSON_OBJECT('total', total, 'passed', passed, 'score', passed / total) as metadata,
    case when (passed / total) >= 0.8 then 'pass'
        else 'fail'
    end as status,
    JSON_OBJECT() as tags
from compliance
    {% endmacro %}