{% macro aws_foundational_security_summary(framework, check_id) %}
  {{ return(adapter.dispatch('aws_foundational_security_summary')(framework, check_id)) }}
{% endmacro %}

{% macro default__aws_foundational_security_summary(framework, check_id) %}{% endmacro %}

{% macro bigquery__aws_foundational_security_summary(framework, check_id) %}
with compliance as (
    select
        count(*) as total,
        SUM(case when status = 'pass' then 1 else 0 end) as passed
    from {{ ref("aws_compliance__foundational_security")}}
)  select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'AWS Foundational Security (Scored)' as title,
    'AWS Foundational Security' as identifier,
    JSON_OBJECT('total', total, 'passed', passed, 'score', passed / total) as metadata,
    case when (passed / total) >= 0.8 then 'pass'
        else 'fail'
    end as status,
    JSON_OBJECT() as tags
from compliance
    {% endmacro %}
