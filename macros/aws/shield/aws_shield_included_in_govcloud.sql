{% macro aws_shield_included_in_govcloud(framework, check_id) %}
  {{ return(adapter.dispatch('aws_shield_included_in_govcloud')(framework, check_id)) }}
{% endmacro %}

{% macro default__aws_shield_included_in_govcloud(framework, check_id) %}{% endmacro %}

{% macro bigquery__aws_shield_included_in_govcloud(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'AWS Shield (Standard) is active on GovCloud accounts' as title,
    "" as identifier,
    JSON_OBJECT() as metadata,
    'pass' as status,
    JSON_OBJECT() as tags
    {% endmacro %}
