{% macro evaluate_cis_compliance(framework, check_id) %}
  {{ return(adapter.dispatch('evaluate_cis_compliance')(framework, check_id)) }}
{% endmacro %}

{% macro default__evaluate_cis_compliance(framework, check_id) %}{% endmacro %}

{% macro bigquery__evaluate_cis_compliance(framework, check_id) %}
{% set ksi_cna_07_excluded_controls = var('ksi_cna_07_excluded_controls') %}

with control_results as (
    SELECT framework, check_id,
       COUNT(CASE WHEN status = 'pass' THEN 1 END) as pass,
       COUNT(CASE WHEN status = 'fail' THEN 1 END) as fail,
    FROM {{ ref('aws_compliance__cis_v3_0_0') }}
    where check_id NOT IN ({{ to_sql_list(var('ksi_cna_07_excluded_controls'))}})
    and account_id IN ({{ to_sql_list(var('ksi_cna_07_account_ids'))}})
    GROUP BY framework, check_id;
)
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Overall AWS CIS compliance' as title,
    "CIS_v3" as identifier,
    JSON_OBJECT(
        'compliance', (control_results.pass / (control_results.fail + control_results.pass)),
        'check_id', control_results.check_id
    ) as metadata,
    case when (control_results.pass / (control_results.fail + control_results.pass)) > .9
        then 'pass'
        else 'fail'
    end as status,
    tags
from control_results
    {% endmacro %}
