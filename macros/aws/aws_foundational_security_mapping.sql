{% macro aws_foundational_security_mapping(framework, check_id, fs_check_id) %}
  {{ return(adapter.dispatch('aws_foundational_security_mapping')(framework, check_id, fs_check_id)) }}
{% endmacro %}

{% macro default__aws_foundational_security_mapping(framework, check_id, fs_check_id) %}{% endmacro %}

{% macro bigquery__aws_foundational_security_mapping(framework, check_id, fs_check_id) %}
select
    '{{ framework }}' as framework,
    '{{ check_id }}' as check_id,
    title,
    resource_id as identifier,
    JSON_OBJECT() as metadata,
    status,
    JSON_OBJECT() as tags
from {{ ref("aws_compliance__foundational_security")}}
where check_id = '{{ fs_check_id }}'

{% endmacro %}