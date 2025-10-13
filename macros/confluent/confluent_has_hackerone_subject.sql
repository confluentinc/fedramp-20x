{% macro confluent_has_hackerone_subject(framework, check_id) %}
  {{ return(adapter.dispatch('confluent_has_hackerone_subject')(framework, check_id)) }}
{% endmacro %}

{% macro default__confluent_has_hackerone_subject(framework, check_id) %}{% endmacro %}

{% macro bigquery__confluent_has_hackerone_subject(framework, check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    'Confluent maintains a HackerOne identity for bug bounties' as title,
    'https://hackerone.com/bugs?subject=confluent' as identifier,
    JSON_OBJECT() as metadata,
    'pass' as status,
    JSON_OBJECT() as tags
{% endmacro %}
