{% macro inspector_vulnerabilities_should_be_resolved_in_sla(framework, check_id) %}
  {{ return(adapter.dispatch('inspector_vulnerabilities_should_be_resolved_in_sla')(framework, check_id)) }}
{% endmacro %}

{% macro default__inspector_vulnerabilities_should_be_resolved_in_sla(framework, check_id) %}{% endmacro %}

{% macro bigquery__inspector_vulnerabilities_should_be_resolved_in_sla(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'Inspector vulnerabilities should be resolved within SLA' as title,
    arn as identifier,
    null as metadata,
    case
        when (findings.severity = 'CRITICAL' and status = 'ACTIVE' and DATE(findings.first_observed_at) <= DATE_SUB(CURRENT_DATE(), INTERVAL 7 DAY))
            then 'fail'
        when (findings.severity = 'HIGH' and status = 'ACTIVE' and DATE(findings.first_observed_at) <= DATE_SUB(CURRENT_DATE(), INTERVAL 14 DAY))
            then 'fail'
        else 'pass'
    end as status,
    case
        when JSON_QUERY(resource, '$.Tags') is not null then JSON_QUERY(resource, '$.Tags')
        else JSON_OBJECT()
    end as tags
from {{ full_table_name("aws_inspector2_findings") }} as findings,
        unnest(JSON_QUERY_ARRAY(findings.resources)) as resource
where TIMESTAMP_TRUNC(_cq_sync_time, DAY) = TIMESTAMP(CURRENT_DATE())
    {% endmacro %}