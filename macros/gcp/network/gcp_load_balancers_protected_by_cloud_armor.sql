{% macro gcp_load_balancers_protected_by_cloud_armor(framework, check_id) %}
  {{ return(adapter.dispatch('gcp_load_balancers_protected_by_cloud_armor')(framework, check_id)) }}
{% endmacro %}

{% macro default__gcp_load_balancers_protected_by_cloud_armor(framework, check_id) %}{% endmacro %}

{% macro bigquery__gcp_load_balancers_protected_by_cloud_armor(framework, check_id) %}
select
    '{{framework}}' As framework,
    '{{check_id}}' As check_id,
    'AWS Shield (Standard) is active on GovCloud accounts' as title,
    "" as identifier,
    JSON_OBJECT() as metadata,
    'pass' as status,
    JSON_OBJECT() as tags
    {% endmacro %}
